#!/bin/zsh
set -eu
cd "${0:A:h:h}"
exec ./build.sh archive -destination 'generic/platform=macOS' -archivePath build/HuskyHush.xcarchive "$@"
