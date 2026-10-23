# Buy dates

Updated 2026-10-23 00:00, at 1.0.

The days to buy STRC to receive each of its two monthly dividends, with the
ex-dividend date after each, so you know when to buy and when you can sell.

## Sub-features

- **The next two buy dates** as cards at the top, each with how many days
  away it is ("Today!", "Tomorrow", "N days away") and its ex-dividend date.
- **Upcoming dates**: every buy date for this month and the next nine, nearest
  first. A date within three days is shown in orange; today and tomorrow get a
  tinted row.
- Each date says to sell after 8 PM ET on the ex-dividend day.
- A buy date stays listed until 9:30 AM ET that day, then drops off.

How a date is found: STRC's record dates are the 15th and the 1st of the next
month. A record date on a weekend or NYSE holiday moves to the trading day
before. The ex-dividend date is the record date (T+1 settlement), and the buy
date is the trading day before that.

## How to get to it

Open Almanac. The dates show once notifications are allowed (see
[Reminders](reminders.md)); before that the screen shows only the header and
the Refresh Notifications button.

## Driving it

Preconditions: Xcode with an iOS simulator runtime; no phone.

`./build.sh drive buy-dates` (~1 min): runs the `AlmanacTests` unit tests in
the simulator. They check trading days (weekends, holidays, observed
holidays, Good Friday), the previous trading day, and buy and ex-dividend
dates for known months.

Last driven: 2026-10-23, iOS 27.1 simulator. 26 tests passed; failed as
expected against a copy whose buy date was the ex-dividend date.

By hand only: the cards, the list and its colours.

## Gotchas

- The NYSE holiday list is written into the app and ends in 2028. From then
  on a holiday counts as a trading day and the dates around it come out wrong,
  with nothing on screen to say so. Add new years when the NYSE publishes them.
- The dates only appear after notification permission is granted, although
  computing them doesn't need it.
