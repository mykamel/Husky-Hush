# Husky Hush

This is a standalone macOS menu bar app; do not modify the parent HuskyWizard app.

## Signing
Use regular Xcode at `/Applications/Xcode.app` (team `7WQUTHQBPG`). The system command-line selection currently points to Xcode beta. `build.sh` pins regular Xcode for this project without changing the global selection.

On 2026-11-14 Xcode Settings > Apple Accounts > Mike West > Manage Certificates showed existing development, Apple Distribution, and Mac Installer Distribution certificates; a GUI build signed successfully. A restricted Codex shell returned zero identities and `xcodebuild` reported No Accounts even though Xcode could sign. Do not conclude credentials are absent from this result. Try `build.sh`; when keychain access is restricted use the Xcode GUI. Never copy private keys into the repository or recreate/revoke certificates for this mismatch.

## Audio behavior
Uses public Core Audio input mute or input volume controls, never audio capture. Muted status must only appear after every discovered input device control reads back the mute target. Unsupported devices must produce a warning. It cannot guarantee blocking unsupported hardware or zero audio during hot plug, driver changes, or between checks. Never market it as a security boundary or a permission blocker.

Verify mute/unmute restores original volumes and reports unsupported devices honestly before submission. App Sandbox stays enabled for Mac App Store distribution.
