# Reminders

Updated 2026-10-25 11:38, at 1.0.

Notifications that tell you, on the day, to buy STRC and later that the sell
window is open, so you don't have to watch the calendar.

## Sub-features

- **Refresh Notifications** asks for permission the first time, then clears
  every pending reminder and schedules three for each STRC date over this month
  and the next nine (60 in all, under iOS's limit of 64):
  - 9:30 AM ET on the buy date: "STRC Buy Date", naming the ex-dividend date.
  - 3:55 PM ET on the buy date: "Market Close in 5 min", the last chance to
    buy in regular hours. Time sensitive.
  - 8:00 PM ET on the ex-dividend date: "Sell Window Open". Time sensitive.
- "Last updated" shows when you last refreshed, until the app is closed.
- With permission off, a red line says notifications aren't enabled.

## How to get to it

Open Almanac and tap Refresh Notifications. Reopen it every few months, since
the reminders only reach ten months ahead.

## Driving it

No check yet. Scheduling goes through the system's notification center, which
needs a permission prompt answered, and there are no UI tests. A unit test
could check which reminders get scheduled for a given month if the schedule
were computed apart from scheduling it.

By hand only: tap Refresh on the phone and see the reminders arrive.

## Gotchas

- Before 2026-10-22 the 3:55 PM reminder fired on the ex-dividend date, a day
  late: a buy that day settles after the record date and misses the dividend.
  Reminders scheduled by an older build stay wrong until the next Refresh.
- Reminders past ten months ahead are never scheduled; nothing reminds you to
  refresh.
- "Last updated" isn't saved, so it's blank each time the app opens.
