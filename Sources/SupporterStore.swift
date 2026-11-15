import Foundation
import Combine
import StoreKit

/// The supporter badge is cosmetic. No microphone behavior depends on this object.
@MainActor final class SupporterStore: ObservableObject {
    static let productID = "mike.west.HuskyHush.supporter"
    @Published private(set) var isPaid = false
    @Published private(set) var product: Product?
    @Published private(set) var isBusy = false
    @Published private(set) var message: String?
    private var updates: Task<Void, Never>?
    private var revision: UInt64 = 0
    private var revokedTransactions: Set<UInt64> = []

    init() {
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result,
                      transaction.productID == Self.productID else { continue }
                self?.apply(transaction)
                await transaction.finish()
            }
        }
    }
    deinit { updates?.cancel() }

    private func apply(_ transaction: Transaction) {
        guard transaction.productID == Self.productID,
              transaction.productType == .nonConsumable else { return }
        revision &+= 1
        if transaction.revocationDate != nil { revokedTransactions.insert(transaction.id) }
        isPaid = transaction.revocationDate == nil && !transaction.isUpgraded
            && !revokedTransactions.contains(transaction.id)
    }

    func refreshEntitlement() async {
        revision &+= 1
        let request = revision
        let result = await Transaction.latest(for: Self.productID)
        guard request == revision else { return }
        // A single non-consumable has no expiry; its latest verified transaction
        // establishes ownership unless Apple has refunded or revoked it.
        guard let result,
              case .verified(let transaction) = result,
              transaction.productID == Self.productID,
              transaction.productType == .nonConsumable else {
            isPaid = false
            return
        }
        apply(transaction)
    }

    func load() async {
        guard !isBusy else { return }
        isBusy = true
        message = nil
        defer { isBusy = false }
        await refreshEntitlement()
        do {
            product = try await Product.products(for: [Self.productID]).first { $0.id == Self.productID && $0.type == .nonConsumable }
            if product == nil { message = "The optional purchase isn’t available right now. Every feature still works free." }
        } catch {
            message = "The App Store couldn’t load the optional purchase. Every feature still works free."
        }
    }

    func purchase() async {
        guard !isBusy, !isPaid, let product else { return }
        isBusy = true
        message = nil
        defer { isBusy = false }
        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result,
                      transaction.productID == Self.productID,
                      transaction.productType == .nonConsumable else {
                    message = "Apple couldn’t verify this purchase. Try Restore Purchase. The app remains fully usable."
                    return
                }
                apply(transaction)
                await transaction.finish()
                message = isPaid ? "Thank you! Your badge now says PAID. All features are exactly the same." : "The purchase hasn’t been confirmed yet. Try Restore Purchase."
            case .pending:
                message = "Waiting for Apple’s purchase approval. You can keep using every feature free."
            case .userCancelled:
                message = "Purchase canceled. Every feature is still free."
            @unknown default:
                message = "The purchase wasn’t confirmed. Every feature is still free."
            }
        } catch StoreKitError.userCancelled {
            message = "Purchase canceled. Every feature is still free."
        } catch {
            message = "The purchase couldn’t be completed. You haven’t lost access to any features."
        }
    }

    func restore() async {
        guard !isBusy else { return }
        isBusy = true
        message = nil
        defer { isBusy = false }
        do {
            try await AppStore.sync()
            await refreshEntitlement()
            message = isPaid ? "Purchase restored. Thank you for supporting Husky Hush!" : "No supporter purchase found for this Apple Account. Every feature is still free."
        } catch StoreKitError.userCancelled {
            message = "Restore canceled. Every feature is still free."
        } catch {
            message = "Apple couldn’t restore the purchase right now. Every feature is still free."
        }
    }
}
