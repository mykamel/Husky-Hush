# Husky Hush

A free macOS menu bar utility for controlling supported microphone inputs. Requires macOS 14 or later.

[Privacy policy](https://mykamel.github.io/Husky-Hush/privacy.html) · [Support](https://mykamel.github.io/Husky-Hush/support.html) · [Report an issue](https://github.com/mykamel/Husky-Hush/issues/new)

## Use

Husky Hush starts in mute mode. Open the menu bar control and explicitly turn microphones on when you want to speak. Turning them on restores settings saved before muting. Close the control window to keep using the menu bar. Quitting leaves device controls unchanged.

## Compatibility

Uses public Core Audio input hardware mute where supported, otherwise writable input-volume controls covering all input channels. Live device-control values and warnings show what can be controlled. The built-in MacBook Pro microphone was verified to switch hardware mute on and off; an attached iPhone/Continuity microphone was detected as unsupported. Other microphones require testing.

The app does not record audio or revoke microphone permissions. Unsupported inputs remain usable by other apps. Hot-plug, driver changes, or changes between checks can briefly pass audio. This is an input-control utility, not a security barrier. Verify your meeting app selects a supported device.

## Optional support

Click the FREE label to open the supporter panel. The purchase is entirely optional, one-time, and cosmetic. Restore Purchase is available. Only verified non-revoked StoreKit entitlements produce PAID. There are no microphone feature gates. The HuskyHush-StoreKit scheme enables local simulated purchases; the normal HuskyHush archive scheme does not. Tests cover free state, cancellation, pending approval, restoration, and refunds.

## Build

Open HuskyHush.xcodeproj in regular Xcode. The shared HuskyHush scheme uses Debug for Run and Release for Archive. Signing team is 7WQUTHQBPG and the bundle identifier is mike.west.HuskyHush; another developer must select their own team and identifier.

`./build.sh` builds a signed Release in a normal Terminal with keychain access. `scripts/archive.sh` creates the distribution archive; `scripts/export.sh` exports using ExportOptions.plist. The script pins /Applications/Xcode.app without changing global developer-tool settings. Restricted shells may be unable to see existing Xcode accounts/certificates; use the Xcode GUI in that situation rather than recreating credentials.

App Sandbox and hardened runtime are enabled. No audio capture, network-client, or Accessibility entitlement is requested. The privacy manifest covers app-local preferences only. No accounts, ads, analytics, subscriptions, or third-party packages are included. The optional $0.99 USD non-consumable supporter purchase changes FREE to PAID only; every feature remains free. Apple handles purchase processing and verification.

## Website and App Store

Static support/privacy pages live in docs/. GitHub Pages is configured to deploy main /docs, and both public page URLs have been verified. Store/listing.json and Store/SUBMISSION.md contain the App Store metadata and remaining release work. Free pricing is configured in App Store Connect. A signed universal 1.0 (1) archive passed Apple validation and was uploaded. The app is in Prepare for Submission; screenshots, review details, privacy agreement acceptance, device testing, and Apple review remain. This repository does not imply approval or public availability.

## License

Copyright © 2026 Mike West. All rights reserved. The app is intended to be offered free of charge; this repository does not grant a separate open-source license.
