import XCTest
import StoreKit
import StoreKitTest
@testable import Husky_Hush

@MainActor final class SupporterPurchaseTests: XCTestCase {
    private var session: SKTestSession!
    override func setUpWithError() throws {
        session = try SKTestSession(configurationFileNamed: "Supporter")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
    }
    override func tearDownWithError() throws {
        session.clearTransactions()
        session = nil
    }
    func testNoPurchaseRemainsFreeAndPriceIsNinetyNineCents() async {
        let store = SupporterStore()
        await store.load()
        XCTAssertFalse(store.isPaid)
        XCTAssertEqual(store.product?.price, Decimal(string: "0.99"))
    }
    func testVerifiedPurchaseSurvivesNewStoreAndRefundRemovesBadge() async throws {
        let store = SupporterStore()
        await store.load()
        await store.purchase()
        XCTAssertTrue(store.isPaid, store.message ?? "No purchase status message")
        let reopened = SupporterStore()
        await reopened.refreshEntitlement()
        XCTAssertTrue(reopened.isPaid, "A new store must read the verified entitlement")
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.refundTransaction(identifier: transaction.identifier)
        await waitForBadge(false, in: reopened)
    }
    func testCancelledPurchaseDoesNotGrantPaidBadge() async throws {
        let store = SupporterStore()
        await store.load()
        try await session.setSimulatedError(.generic(.userCancelled), forAPI: .purchase)
        await store.purchase()
        XCTAssertFalse(store.isPaid)
        XCTAssertTrue(store.message?.lowercased().contains("cancel") == true)
    }
    func testPendingPurchaseWaitsForApproval() async throws {
        session.askToBuyEnabled = true
        let store = SupporterStore()
        await store.load()
        await store.purchase()
        XCTAssertFalse(store.isPaid)
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.approveAskToBuyTransaction(identifier: transaction.identifier)
        await waitForBadge(true, in: store)
    }
    func testRestoreRecognizesPriorPurchase() async throws {
        _ = try await session.buyProduct(identifier: SupporterStore.productID)
        let store = SupporterStore()
        await store.restore()
        XCTAssertTrue(store.isPaid, store.message ?? "No purchase status message")
    }
    private func waitForBadge(_ expected: Bool, in store: SupporterStore) async {
        for _ in 0..<40 {
            if store.isPaid == expected { return }
            try? await Task.sleep(for: .milliseconds(50))
            await store.refreshEntitlement()
        }
        XCTAssertEqual(store.isPaid, expected, "StoreKit must deliver the changed entitlement")
    }

}
