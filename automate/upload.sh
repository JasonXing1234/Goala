#!/bin/bash

# Set exit if fail
set -e

echo "Did you update version number and build number? Press 'Ctrl+C' to cancel"
# Wait for user confirmation.
read -r

# Build the flutter app
flutter clean
flutter build ipa

# Get password
source secrets.sh

# Upload the app
xcrun altool --upload-app --type ios \
    -f build/ios/ipa/*.ipa \
    -apiKey "$ISSUER" \
    -apiIssuer "$KEY"

