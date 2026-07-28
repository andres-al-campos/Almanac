# Almanac

An iOS app that notifies you when to buy STRC to capture its dividend.

## What it does

STRC pays a dividend twice a month. To receive it you have to hold the stock
through the ex-dividend date, which means buying by a specific day that shifts
around weekends and NYSE holidays. Almanac computes those buy dates and schedules
local notifications at 9:30 AM ET (market open) on each one, so you don't have to
track the calendar yourself.

It's offline, has no dependencies, and once you refresh notifications it runs on
its own.

## STRC's two monthly dates

STRC has two record dates each month:

1. The **15th** of the month.
2. The **1st of the following month**.

For each, Almanac walks back to the buy date:

1. **Record date** → if it's a weekend or NYSE holiday, shift to the prior trading day.
2. **Ex-dividend date** = the record date under T+1 settlement (or the prior trading day if the record date isn't a trading day).
3. **Buy date** = the trading day before ex-div. **This is when you're notified.**

Example: a record date of Saturday the 15th shifts to Friday the 14th (ex-div),
so the buy-date notification fires Thursday the 13th at 9:30 AM ET.

The NYSE holiday calendar is built in through 2028 (federal holidays plus Good
Friday). When the NYSE publishes 2029+ dates, add them to the `nyseHolidays`
array in `Almanac/Models/TradingCalendar.swift`.

> SATA was previously tracked too, but it switched to daily dividend payments —
> every trading day is an ex-div day, so there's no buy date to time. It was
> removed.

## Build & install

The app installs to your own iPhone via a single script. You need Xcode's
command-line tools and an Apple ID signed in to Xcode (a free account works).

```bash
cp Config.xcconfig.example Config.xcconfig   # then set DEVELOPMENT_TEAM to your Apple Team ID
./build.sh                                   # build, sign, and install to the connected iPhone
```

`Config.xcconfig` is gitignored, so your team ID stays local. Find your Team ID
in Xcode → Settings → Accounts → your team. Connect your iPhone via USB (unlocked)
or pair it over Wi-Fi in Xcode → Window → Devices and Simulators.

`./build.sh -h` lists the flags (`--no-install` to build without deploying,
`--device <id>` to target a specific phone, `-v` for verbose output).

A free-account signature expires after about 7 days. Re-run `./build.sh` to renew
it, or use [ReSign](https://github.com/andres-al-campos/ReSign) to renew automatically.

## First launch

Tap **Refresh Notifications** and grant permission. The app schedules 60
notifications (10 months × 2 STRC dates × 3 reminders each: buy date, approaching
close, and sell window). Reopen it every few months to extend the window.

## Requirements

- iOS 15.0+
- SwiftUI, no external dependencies
- Stays under the iOS 64-notification limit (uses 60)

## License

MIT.

## Disclaimer

Almanac computes dates from STRC's declared schedule and the NYSE calendar.
Verify ex-dividend dates against official sources before trading.
