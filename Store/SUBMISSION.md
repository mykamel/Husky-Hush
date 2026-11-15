# App Store submission

Repository: https://github.com/mykamel/Husky-Hush
Marketing URL: https://mykamel.github.io/Husky-Hush/
Privacy policy URL: https://mykamel.github.io/Husky-Hush/privacy.html
Support URL: https://mykamel.github.io/Husky-Hush/support.html

## Xcode configuration

- Project/scheme: HuskyHush (shared), macOS 14+.
- Bundle ID: mike.west.HuskyHush.
- Team: 7WQUTHQBPG, automatic signing.
- Version/build: 1.0 (3), editable in target build settings.
- Category: Utilities.
- App Sandbox and hardened runtime enabled.
- No audio capture, network client, or Accessibility entitlements.
- App icon includes all required macOS sizes.
- Privacy manifest declares only app-local UserDefaults access (CA92.1), no tracking or collected data.
- Release archive uses dSYM symbols; app is included in the archive.
- ExportOptions.plist targets App Store Connect with automatic distribution/installer signing and local export.

## Archive and upload

In regular Xcode open HuskyHush.xcodeproj, choose the shared HuskyHush scheme and Any Mac, then Product > Archive. In Organizer use Distribute App > App Store Connect. For a normal Terminal with keychain access: scripts/archive.sh, then scripts/export.sh. Increment the build number for every new uploaded build. Never store certificates or private keys in this repository.

## App Store Connect fields

Use listing.json for the product name, description, keywords, review notes, and URLs. Select Free for every territory. The optional cosmetic supporter purchase is sold separately. Choose Data Not Collected in App Privacy. Complete the current age-rating questionnaire based on this microphone utility's actual content; no user-generated content, messaging, advertising, or restricted material is included. Review Apple's export-compliance questions; the app implements no custom encryption.

Supply actual app screenshots at Apple's accepted Mac dimensions. No sign-in is required. App Review should test the built-in microphone and confirm that unsupported hardware produces a warning. No review credentials are needed.

## Completed on November 14, 2026

- Repository created and full source/icon uploaded: mykamel/Husky-Hush. Local main matches GitHub main.
- GitHub Pages enabled from main /docs with HTTPS. Privacy and support URLs opened and verified in Safari.
- Signed universal archive 1.0 (1) created in Xcode Organizer for Intel and Apple silicon.
- Xcode reported: Your app successfully passed all validation checks.
- Xcode reported: Husky Hush 1.0 (1) uploaded.
- App Store Connect app created: https://appstoreconnect.apple.com/apps/6835004758/distribution
- Description, keywords, support URL, marketing URL, copyright, no-sign-in requirement, and review notes saved.
- Privacy policy URL saved. Data Not Collected responses saved as a draft.
- $0.00 base price and comparable free prices configured for 175 regions; worldwide availability configured for release.

## Submitted November 14, 2026

- Apple confirmed **2 Items Submitted**: macOS version 1.0 build 3 and Optional Supporter Badge.
- App status: **Waiting for Review**. Submission ID: 405163f5-ad01-4fa4-9db4-e68bc8bcf7b4.
- Privacy responses published: Data Not Collected.
- Two real app screenshots uploaded at 1440 × 900; the supporter disclosure screenshot is also attached to the IAP review information.
- Review contact information and build 3 review notes saved in App Store Connect; private contact details are not stored here.
- Utilities category, subtitle, content rights, and 4+ age-rating questionnaire completed.
- Build 3 encryption declaration saved: none of the listed encryption algorithms are implemented.
- Free app pricing and automatic release after approval retained. The purchase remains entirely optional and changes only FREE to PAID.
- Review submission is not App Store approval or public availability.

### Validation limits

Hardware mute control readback and StoreKit flows were verified. Recording attenuation in a meeting app, Intel hardware, and every third-party USB/Bluetooth device have not been independently tested. Unsupported controls remain explicitly flagged.

## Optional supporter purchase

- Product: mike.west.HuskyHush.supporter (App Store Connect ID 6835006560).
- One-time non-consumable, $0.99 USD base price; local equivalent shown by StoreKit.
- Product title: Support Husky Hush.
- Store description: Optional FREE to PAID label. All features stay free.
- Product pricing, all-region availability, English localization, and review notes are saved in App Store Connect. Its review screenshot is attached and it was submitted with app version 1.0 build 3.
- No features depend on the purchase. The only cosmetic benefit is changing FREE to PAID in the panel header. No subscription, purchase nag, or automatic purchase prompt.
- Verified StoreKit transaction updates handle approval and revocation. Restore Purchase is present. No developer-operated payment server or payment-card storage.
- Five StoreKit tests passed in Xcode using the HuskyHush-StoreKit scheme: free/price, cancellation, pending approval, restoration, and refund. The production HuskyHush scheme does not enable simulated transactions or run these environment-specific tests.
- The app description and review notes have been updated in App Store Connect. Privacy/support pages now describe Apple purchase processing while retaining Data Not Collected for developer collection.

- Final signed universal build 1.0 (3), with the fully visible two-line optional-payment disclosure, uploaded successfully in Xcode. Build 1.0 (2) was also uploaded before this layout refinement. Use build 3 for review.
