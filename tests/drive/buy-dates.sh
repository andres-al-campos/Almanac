#!/bin/bash
# Drive: the buy-date math, by AlmanacTests in an iOS simulator. Needs no phone.
cd "$(dirname "$0")/../.."

# An iPhone on the newest iOS runtime, by id: a destination by name picks a runtime
# that may not match the SDK, and xcodebuild then finds no device at all.
sim=$(xcrun simctl list devices available -j 2>/dev/null | /usr/bin/python3 -c '
import json, sys
d = json.load(sys.stdin)["devices"]
ios = sorted((k for k in d if ".iOS-" in k), key=lambda k: [int(n) for n in k.rsplit("iOS-", 1)[1].split("-")])
print(next((x["udid"] for k in reversed(ios) for x in d[k] if x["name"].startswith("iPhone")), ""))')
if [ -z "$sim" ]; then
    echo "✗ buy-dates: no iPhone simulator found. Install an iOS runtime in Xcode → Settings → Components, then run again."
    exit 1
fi

log=build/drive.log
mkdir -p build
if xcodebuild test -project Almanac.xcodeproj -scheme Almanac \
    -destination "platform=iOS Simulator,id=$sim" -derivedDataPath build/TestData \
    -only-testing:AlmanacTests > "$log" 2>&1; then
    n=$(grep -oE 'Executed [0-9]+ tests?' "$log" | tail -1 | sed 's/Executed //')
    echo "✓ buy-dates: $n passed in the simulator"
    exit 0
fi
echo "✗ buy-dates: tests failed in the simulator. The failures:"
grep -E "error: |failed \(" "$log" | head -20 | sed 's/^/    /'
echo "    Full log: $log"
exit 1
