# Almanac

An iOS app built and installed from the command line. `build.sh` is the entry
point — prefer it over raw `xcodebuild`, and never build by driving the Xcode GUI.

```
./build.sh              build, sign, install to the connected iPhone
./build.sh --no-install build and sign only (use this to check it compiles)
./build.sh --device <id> target a specific device
./build.sh -v           verbose xcodebuild output
```

The no-arg path leaves the app installed on the phone rather than stopping at a
`.app` in a build directory. Do not add a build-only default.

## Signing

`DEVELOPMENT_TEAM` lives in `Config.xcconfig`, which is **gitignored** because a
Team ID is machine-specific. `Config.xcconfig.example` is the committed template.
Never commit a real Team ID.

Builds are signed with a personal Apple ID, so they stop opening after 7 days.
Re-running `./build.sh` renews them.

## The project file

This project commits its `.xcodeproj` rather than generating it — unlike the
newer ones, which use xcodegen and a `project.yml`. `MARKETING_VERSION` in
`Almanac.xcodeproj/project.pbxproj` is the version's single source of truth, and
`release.sh` reads it from there.

Converting to xcodegen would let this project adopt
`~/Projects/Code/ios-template` wholesale. That is a real change, not a cleanup —
do not start it as a side effect of another task.

## build.sh is generated

`build.sh` comes from `walled_garden/_template/ios-build.sh`. A bug in it is a bug
in the template: fix it there and run `walled_garden/_template/sync-build-scripts.sh`,
rather than patching this copy and letting the three projects drift apart again.
`sync-build-scripts.sh --check` reports drift without writing.

`release.sh` is *not* generated yet — the three copies have diverged, and the
two non-xcodegen projects read the version from a different file than Somnya.
