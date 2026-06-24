#!/bin/bash
set -euo pipefail

# ─── Usage ────────────────────────────────────────────────────────────
# ./build.sh                        # run tests + build IPA
# ./build.sh --skip-tests           # skip tests, just build IPA
# ./build.sh com.you.almanac        # use a custom bundle ID
# ./build.sh --skip-tests com.you.almanac

# ─── Parse args ───────────────────────────────────────────────────────
SKIP_TESTS=false
BUNDLE_ID="com.alejandro.almanac"

for arg in "$@"; do
    if [ "$arg" = "--skip-tests" ]; then
        SKIP_TESTS=true
    elif [ "$arg" != "--skip-tests" ]; then
        BUNDLE_ID="$arg"
    fi
done

# ─── Config ───────────────────────────────────────────────────────────
SCHEME="Almanac"
PROJECT="Almanac.xcodeproj"
SIMULATOR_ID="5BFBF525-C31F-4717-A19E-7891120A3708"  # iPhone 16
EXPORT_OPTIONS="ExportOptions.plist"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/Almanac.xcarchive"
IPA_DIR="$BUILD_DIR"

echo "Bundle ID: $BUNDLE_ID"
echo "(pass a different one as: ./build.sh com.yourname.almanac)"

# ─── Clean ────────────────────────────────────────────────────────────
echo ""
echo "==> Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ─── Test ─────────────────────────────────────────────────────────────
if [ "$SKIP_TESTS" = false ]; then
    echo ""
    echo "==> Running tests..."
    xcodebuild test \
        -scheme "$SCHEME" \
        -project "$SCRIPT_DIR/$PROJECT" \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -quiet

    echo "    Tests passed."
else
    echo ""
    echo "==> Skipping tests (--skip-tests)"
fi

# ─── Archive ──────────────────────────────────────────────────────────
echo ""
echo "==> Archiving..."
echo "    (your iPhone must be connected or registered for signing to work)"
xcodebuild archive \
    -scheme "$SCHEME" \
    -project "$SCRIPT_DIR/$PROJECT" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
    -quiet

echo "    Archive created."

# ─── Export IPA ───────────────────────────────────────────────────────
echo ""
echo "==> Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$IPA_DIR" \
    -exportOptionsPlist "$SCRIPT_DIR/$EXPORT_OPTIONS" \
    -allowProvisioningUpdates \
    -quiet

echo "    IPA exported."

# ─── Done ─────────────────────────────────────────────────────────────
IPA_FILE="$IPA_DIR/Almanac.ipa"
if [ -f "$IPA_FILE" ]; then
    SIZE=$(du -h "$IPA_FILE" | cut -f1)
    echo ""
    echo "==> Done! $IPA_FILE ($SIZE)"
    echo "    AirDrop to your phone → open in SideStore → install."
else
    echo ""
    echo "==> ERROR: IPA not found at expected path."
    echo "    Check $IPA_DIR for the exported file."
    ls -la "$IPA_DIR"
    exit 1
fi
