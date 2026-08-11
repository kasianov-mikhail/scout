# Manual Testing

Automated coverage is broad — 829 tests across 88 suites, plus CI gates for public API breakage, Core Data model versions, and the scout-server wire contract. This checklist covers only what those tests structurally cannot reach: real backends, real crashes, real devices, and the parts of the SwiftUI surface that no automated check guards.

A full pass takes roughly 1–2 hours on one device. Most sections are conditional — run them when a change touches the area named in the heading.

## Before a release

Run the whole checklist once, on a physical device, against a real CloudKit container. The simulator hides signal delivery, background execution limits, and iCloud account states.

Suggested configuration: the oldest supported OS (iOS 16) for one pass and the newest (iOS 27) for another. CI runs the full `.github/matrix/ios.json` matrix nightly but only iOS 26 Debug per pull request, so version-specific rendering differences reach a release unverified.

## CloudKit backend

Automated tests drive `NativeConnector` through an in-memory store ([NativeDatabase+InMemory.swift](../Tests/Connectors/Native/NativeDatabase+InMemory.swift)), so nothing below is covered.

- [ ] Fresh container: schema uploads, first records appear in the CloudKit dashboard
- [ ] Records written by a previous version still read back after a schema change
- [ ] iCloud signed out — dashboard degrades gracefully, no crash, no silent data loss
- [ ] Airplane mode during a sync — records queue and deliver on reconnect
- [ ] Account switch mid-session
- [ ] Backend health reflects real state in [BackendDetailView.swift](../Sources/ScoutUI/Home/Settings/BackendDetailView.swift)

## Crash and hang capture

Suites under [Diagnostics/Crash](../Tests/ScoutTests/Diagnostics/Crash) and [Diagnostics/Hang](../Tests/ScoutTests/Diagnostics/Hang) cover archiving, fingerprinting, and serialization. The interception itself — `SignalHandler`, `ExceptionHandler`, and the C watchdog in [CScoutHang.c](../Sources/CScoutHang/CScoutHang.c) — only fires on a real fault.

- [ ] Force an uncaught Objective-C exception, relaunch, confirm the crash reaches the timeline with a usable stack trace
- [ ] Force a signal crash (`SIGSEGV` or a deliberate `fatalError`), relaunch, confirm the same
- [ ] Block the main thread for 4 s, confirm a warning-level hang is recorded with a backtrace; block it for 9 s and confirm the critical-level one (thresholds are 3 s and 8 s)
- [ ] Crash during the crash upload itself — the archive survives and retries on next launch
- [ ] Two crashes with the same signature group into one incident; different signatures do not

Debugger attachment suppresses signal handlers — run these from a build launched without Xcode attached.

## Core Data migration

`coredata.yml` and [MigrationTests.swift](../Tests/ScoutTests/Persistence/MigrationTests.swift) validate the model graph, not a user's store. Run this whenever `ScoutModel.xcdatamodeld` gains a version.

- [ ] Install the previous release, generate events, crashes, and metrics
- [ ] Update in place to the new build — no store reset, all prior data readable
- [ ] Repeat skipping a version, if more than one shipped since the last check
- [ ] Confirm the sync queue survives migration and drains afterwards

## Lifecycle

Install, session, launch, and version tracking are unit-tested against an injected clock, which cannot reproduce disagreement with the system's own notifications.

- [ ] Cold launch, background, foreground, kill, relaunch — session boundaries land where expected
- [ ] Version bump produces a version record; reinstall produces a fresh install record
- [ ] Time zone change and manual date change mid-session
- [ ] Backgrounded upload interrupted by expiring background execution time resumes later
- [ ] Device reboot with pending unsynced records

## Dashboard UI

143 view files in `ScoutUI`. Providers and models are unit-tested; layout, navigation, and interaction are not. This is the largest block of manual work.

- [ ] Home: every section navigates and returns without state loss
- [ ] Onboarding flow end to end on a fresh install ([Onboarding](../Sources/ScoutUI/Home/Onboarding))
- [ ] Connection menu switches backends and the dashboard rereads from the new one
- [ ] Pull-to-refresh and the periodic refresh in [Primitives/Refresh](../Sources/ScoutUI/Primitives/Refresh)
- [ ] Date range pickers and the calendar under [Primitives/Calendar](../Sources/ScoutUI/Primitives/Calendar)
- [ ] Charts: activity, retention cohorts, metric distributions, series
- [ ] Empty, loading, and error states on every list
- [ ] Search across the index and results
- [ ] Share/export buttons produce valid Markdown and open the share sheet
- [ ] Dark mode
- [ ] Largest Dynamic Type size — no clipping, no overlap
- [ ] Landscape and iPad layout
- [ ] Scroll performance on a large dataset (use the demo connector's fullest scenario)

## Alerts

[ScoutAlerts.swift](../Sources/ScoutUI/Monitoring/Alerts/Delivery/ScoutAlerts.swift) and `AlertRefreshScheduler` depend on background scheduling that no unit test triggers.

- [ ] Notification permission prompt and denial path
- [ ] An alert condition crossing its threshold produces exactly one notification
- [ ] Tapping the notification deep-links to the right incident
- [ ] Refresh scheduling survives backgrounding

## Reducing this list

The dashboard section is the part worth chipping away at: its views render from fixtures, so much of it is reachable by automated checks. Everything above it needs real hardware, a real backend, or a real crash, and cannot be automated away.
