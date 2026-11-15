#!/bin/zsh
set -eu
cd "${0:A:h:h}"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
exec xcrun xcodebuild -exportArchive -archivePath build/HuskyHush.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/AppStore -allowProvisioningUpdates "$@"
