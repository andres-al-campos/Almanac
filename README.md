# Project Almanac

Automated iOS app for STRC and SATA dividend buy date notifications.

## Overview

Project Almanac calculates optimal buy dates for monthly dividend capture strategies on STRC and SATA preferred stocks. The app schedules local notifications at market open (9:30 AM ET) on the day you need to buy to receive the dividend.

## Features

- 🔔 Notifications at 9:30 AM ET (market open) on buy dates
- 📅 STRC: 15th-of-month ex-dividend schedule
- 📅 SATA: End-of-month ex-dividend schedule
- ⚙️ Automatic weekend/holiday adjustments using official NYSE calendar
- 🔄 Schedules 2 years of notifications automatically
- 📱 Fully offline, no internet required
- 🌾 Set it and forget it - "harvesting yields" on schedule

## How It Works

### Date Calculation Logic

1. **Record Date**: Declared dividend date (15th for STRC, last day for SATA)
2. **Weekend/Holiday Adjustment**: Shifts to previous business day if needed
3. **Ex-Dividend Date**: 1 business day before record date (T+1 settlement)
4. **Buy Date**: 1 business day before ex-div ← **You get notified here**

**Example:**
- STRC dividend record date: 15th (Saturday)
- Adjusted record date: Friday 14th
- Ex-div date: Thursday 13th
- **Buy date notification: Wednesday 12th at 9:30 AM ET**

### NYSE Calendar

Includes official market holidays through 2028:
- All federal holidays + Good Friday
- Data sourced from NYSE official announcements

## Installation

### Quick Start

1. Install SideStore or AltStore on your iPhone
2. Open `Almanac.xcodeproj` in Xcode
3. Change Bundle Identifier to something unique (e.g., `com.yourname.almanac`)
4. Build and export IPA
5. Sideload via SideStore/AltStore
6. Open app, grant notifications, done!

See `QUICKSTART.md` for detailed step-by-step instructions.

### First Launch

1. Tap "Refresh Notifications"
2. Grant notification permission
3. App schedules 48 notifications (2 years × 24 per year)
4. Close app - notifications are set!

## Usage

- Notifications fire at 9:30 AM ET (auto-converts to your timezone)
- Open app once per year to refresh (or when prompted)
- Check "Next STRC Buy" and "Next SATA Buy" anytime

## Architecture

```
Almanac/
├── Models/
│   └── TradingCalendar.swift      # Holiday calendar & date calculations
├── Managers/
│   └── NotificationManager.swift  # Notification scheduling
└── Views/
    └── ContentView.swift          # UI
```

## Maintenance

### Yearly Refresh

Open app once in January to keep notifications fresh for next 2 years.

### Future Holiday Updates

When NYSE publishes 2029+ holidays:
1. Edit `TradingCalendar.swift`
2. Add new dates to `nyseHolidays` array
3. Rebuild and reinstall

## Technical Details

- **iOS 15.0+** required
- **64 local notifications** max (we use 48)
- **SwiftUI** interface
- **No external dependencies**
- **Offline-first** architecture

## License

MIT - Do whatever you want

## Disclaimer

This app calculates dates based on declared schedules and NYSE calendar. Always verify ex-dividend dates with official sources before trading.

---

**Project Almanac** - Harvesting yields on schedule since 2026 🌾
