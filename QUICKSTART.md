# Quick Start - Project Almanac

## Prerequisites

1. **Mac with Xcode** (free from App Store)
2. **iPhone running iOS 15+**
3. **SideStore** (recommended) or **AltStore** installed

## Step 1: Install SideStore

### Recommended: SideStore
- Visit: https://sidestore.io
- Follow installation guide
- Apps don't expire (unlike AltStore's 7-day limit)

### Alternative: AltStore  
- Visit: https://altstore.io
- Easier setup but requires weekly refresh

## Step 2: Open in Xcode

```bash
cd /Users/alejandro/Projects/Code/Almanac
open Almanac.xcodeproj
```

Or just double-click `Almanac.xcodeproj`

## Step 3: Change Bundle Identifier

**CRITICAL: Must change or install will fail**

1. Click "Almanac" (blue icon) in left sidebar
2. Select "Almanac" under TARGETS
3. Go to "Signing & Capabilities" tab
4. Change `com.almanac.app` to something unique:
   - `com.alex.almanac`
   - `com.yourname.almanac`
   - Anything unique works!

## Step 4: Build IPA

### For Apple Silicon Mac (M1/M2/M3):
1. Top of Xcode: Select "Any iOS Device (arm64)"
2. Product → Archive
3. Wait for build
4. Click "Distribute App"
5. Select "Custom" → Next
6. Select "Development" → Next
7. Select "Automatically manage signing" → Next
8. Click "Export"
9. Save to Desktop
10. You now have `Almanac.ipa`

### For Intel Mac:
1. Connect iPhone via USB
2. Select your iPhone from device dropdown
3. Product → Archive
4. Follow steps 4-10 above

## Step 5: Install on iPhone

### SideStore:
1. Open SideStore on iPhone
2. Tap "+" icon
3. Select `Almanac.ipa`
4. App installs automatically

### AltStore:
1. Open AltStore on iPhone
2. Go to "My Apps"
3. Tap "+"
4. Select IPA (may need to AirDrop it first)

## Step 6: First Launch

1. Open "Almanac" from home screen
2. Tap "Refresh Notifications"
3. iOS prompts for permission → Tap "Allow"
4. App schedules 48 notifications
5. Done! Close the app

## Verify It Works

Settings → Notifications → Almanac should show "ON"

Check the app to see:
- "Next STRC Buy: [date]"
- "Next SATA Buy: [date]"
- "48 notifications scheduled"

## Troubleshooting

**"Unable to Install"**
- Did you change Bundle Identifier in Step 3?
- Try a different identifier

**"Untrusted Developer"**
- Settings → General → VPN & Device Management
- Tap your profile → Trust

**No notifications appearing**
- Settings → Notifications → Almanac → Turn ON
- Open app, tap "Refresh Notifications"

**Xcode build errors**
- Update Xcode from App Store
- Product → Clean Build Folder, try again

## Maintenance

**SideStore users:** Never expires!

**AltStore users:** Refresh every 7 days in AltStore

**Everyone:** Open app once per year (like January) to refresh notifications

---

That's it! You'll get notified at 9:30 AM ET (your timezone) on every STRC and SATA buy date. 

Never miss a dividend harvest again 🌾
