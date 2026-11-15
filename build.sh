#!/bin/zsh
set -eu
cd "${0:A:h}"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
if [[ ! -x "$DEVELOPER_DIR/usr/bin/xcodebuild" ]]; then
  print -u2 'Regular Xcode is unavailable at /Applications/Xcode.app.'
  exit 1
fi
if ! /usr/bin/security find-identity -v -p codesigning 2>/dev/null | /usr/bin/grep -q '"'; then
  print -u2 'No signing identities are visible to this shell. This does not prove Xcode has no credentials.'
  print -u2 'Open HuskyHush.xcodeproj in regular Xcode and check Settings > Apple Accounts > Manage Certificates.'
  print -u2 'If Xcode sees them, this shell may lack access to the login keychain. Build/archive in Xcode.'
  print -u2 'Do not recreate certificates, export private keys, or change keychain security to fix a restricted shell.'
  exit 2
fi
action="${1:-build}"
if (( $# > 0 )); then shift; fi
exec /usr/bin/xcrun xcodebuild -project HuskyHush.xcodeproj -scheme HuskyHush -configuration Release -derivedDataPath build -allowProvisioningUpdates "$action" "$@"
