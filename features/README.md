# Almanac features

Updated 2026-10-23 00:00, at 1.0.

What a user can do with Almanac, how to reach it, and how to drive it. Read
this before adding anything: if it's already here, extend it instead of
building it again.

| Feature | File | Platforms | Driveable headless? |
|---|---|---|---|
| Buy dates | [buy-dates.md](buy-dates.md) | iOS | Yes: the date math, by unit tests in the simulator |
| Reminders | [reminders.md](reminders.md) | iOS | No check yet |

## What counts as a feature

Something a user sets out to do, with its own way in. What you only reach
inside a feature is a sub-feature and lives in that feature's file.

## Each file has

- **Sub-features**: what a user can do inside it, including limits.
- **How to get to it**: the user's path.
- **Driving it**: preconditions, the command that checks it, and what it
  observes. With no check, "No check yet" and why.
- **Gotchas**: what has bitten us or will.

Claims describe observable behavior, not code locations.

## Keeping it current

Update a feature's file in the same commit that changes the feature. A
feature touched for the first time gets a file and a row here.

## Driving conventions

`./build.sh check` runs every law in `laws/`, including the one that keeps
this map and its files in step, then every drive.

A feature's check is `drive/<name>.sh`. `./build.sh drive` runs them all and
`./build.sh drive <name>` runs one; a name with no script is an error.

Almanac has a unit test target (`AlmanacTests`) and no UI tests. A drive runs
the unit tests on an iOS simulator; nothing needs a phone.
