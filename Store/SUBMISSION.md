# App Store submission

Repository: https://github.com/mykamel/Husky-Hush
Marketing URL: https://mykamel.github.io/Husky-Hush/
Privacy policy URL: https://mykamel.github.io/Husky-Hush/privacy.html
Support URL: https://mykamel.github.io/Husky-Hush/support.html

## Xcode configuration

- Project/scheme: HuskyHush (shared), macOS 14+.
- Bundle ID: mike.west.HuskyHush.
- Team: 7WQUTHQBPG, automatic signing.
- Version/build: 1.0 (1), editable in target build settings.
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

Use listing.json for the product name, description, keywords, review notes, and URLs. Select Free for every territory (no in-app purchases). Choose Data Not Collected in App Privacy. Complete the current age-rating questionnaire based on this microphone utility's actual content; no user-generated content, messaging, advertising, purchases, or restricted material is included. Review Apple's export-compliance questions; the app implements no custom encryption.

Supply actual app screenshots at Apple's accepted Mac dimensions. No sign-in is required. App Review should test the built-in microphone and confirm that unsupported hardware produces a warning. No review credentials are needed.

## Still requires completion/verification

- Verify GitHub Pages deployment and both public page URLs.
- Create the App Store Connect app record and reserve the bundle ID if Xcode has not registered it.
- Confirm Free pricing in App Store Connect; JSON pricing is only preparation.
- Upload an archived distribution build, screenshots, privacy declarations, and age/export answers.
- Verify actual silence in a meeting app with the selected supported microphone.
- Test login, wake/device changes, and Bluetooth/USB compatibility. Intel build compilation is not Intel hardware testing.
- Submit for Apple review and await approval. No local file or archive implies publication.
