#!/bin/bash
# Cut a GitHub release for the current version of Almanac.
#
# Reads the version from MARKETING_VERSION in the Xcode project (the single
# source of truth), verifies the version builds, tags it v<version>, and creates
# a GitHub release with auto-generated notes.
#
# No artifact is attached. Almanac is a sideloaded iOS app: a .app from build.sh
# is signed with the maintainer's Apple Team and expires in ~7 days, so it won't
# install for anyone else. The unit of distribution is the source — each user
# clones, sets their own DEVELOPMENT_TEAM in Config.xcconfig, and runs ./build.sh.
# The release marks a version; it doesn't ship a binary.
#
# Usage:
#   ./release.sh          # verify build, tag, and publish the release
#   ./release.sh -h       # this help
#
# Safety: refuses to run on a dirty or unpushed tree, and won't overwrite an
# existing version. To release a new version, bump MARKETING_VERSION in
# Almanac.xcodeproj/project.pbxproj first, commit, and push.

set -e

APP_NAME=Almanac

case "${1:-}" in
    -h|--help)
        sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
    "") ;;
    *)
        echo "error: unknown flag '$1'. Run '$0 --help' for usage."
        exit 1
        ;;
esac

cd "$(dirname "$0")"

# --- Preflight: tooling ---
if ! command -v gh >/dev/null 2>&1; then
    echo "error: GitHub CLI (gh) not installed. Install with: brew install gh, then run 'gh auth login'."
    exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
    echo "error: not signed in to GitHub CLI. Run 'gh auth login' (GitHub.com → HTTPS → browser), then re-run ./release.sh."
    exit 1
fi

# --- Read the version (single source of truth) ---
VERSION=$(grep -E 'MARKETING_VERSION' Almanac.xcodeproj/project.pbxproj | head -1 | sed -E 's/.*MARKETING_VERSION = ([^;]+);.*/\1/' | tr -d '"' | xargs)
if [ -z "$VERSION" ]; then
    echo "error: couldn't read MARKETING_VERSION from Almanac.xcodeproj/project.pbxproj. Confirm a line 'MARKETING_VERSION = x.y;' exists."
    exit 1
fi
TAG="v$VERSION"

# --- Safety: clean, pushed tree ---
if [ -n "$(git status --porcelain)" ]; then
    echo "error: working tree has uncommitted changes. Commit or stash them so the release tag matches what's published, then re-run ./release.sh."
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git fetch --quiet origin "$BRANCH" 2>/dev/null || true
if [ -n "$(git log "origin/$BRANCH..HEAD" --oneline 2>/dev/null)" ]; then
    echo "error: local commits aren't pushed to origin/$BRANCH. Run 'git push' first so the release reflects what's on GitHub, then re-run ./release.sh."
    exit 1
fi

# --- Safety: don't clobber an existing version ---
if git rev-parse "$TAG" >/dev/null 2>&1 || gh release view "$TAG" >/dev/null 2>&1; then
    echo "error: $TAG already exists. Bump MARKETING_VERSION in Almanac.xcodeproj/project.pbxproj, commit, and push before releasing a new version."
    exit 1
fi

# --- Verify the version compiles (build only, no signing/install needed) ---
# A release should never tag a version that doesn't build. We don't need the
# signed artifact, just proof the sources compile — so skip code signing.
echo "→ Verifying $APP_NAME $VERSION builds..."
DERIVED_DATA="$(mktemp -d)"
trap 'rm -rf "$DERIVED_DATA"' EXIT
xcodebuild build \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Debug \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    -quiet
echo "  build OK."

# --- Tag and publish (notes only, no artifact) ---
echo "→ Tagging $TAG and creating GitHub release"
git tag "$TAG"
git push origin "$TAG"
gh release create "$TAG" \
    --title "$APP_NAME $VERSION" \
    --generate-notes

echo "✓ Released $TAG (source-only; clone and run ./build.sh to install)."
