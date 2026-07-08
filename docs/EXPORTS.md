# Exports

Every list and detail screen in the dashboard — devices, network requests, events, the crash and hang timeline, and incident groups — has a share button that renders its data as a Markdown document instead of a screenshot, so it pastes cleanly into an issue or a chat. This shows what each one looks like; dates below are illustrative and move with the sample data.

The device roster (`DevicesExport`):
```
# Scout Devices
3 devices

- iPhone15,3  (iOS 17.4, 812 sessions, 3 crashes, seen 2026-07-08T14:48:56Z)
- iPhone15,3  (iOS 17.3, 540 sessions, 0 crashes, seen 2026-07-08T12:03:56Z)
- iPhone14,2  (iOS 17.4, 391 sessions, 1 crash, seen 2026-07-08T09:03:56Z)
```

A network report over a time range (`NetworkReportExport`):
```
# Scout Network Report
2026-07-07 21:00–2026-07-08 21:00 · 18590 requests · success 98.12% · p99 9.6 s

## Status codes
- 2xx: 18030 requests
- 3xx: 210 requests
- 4xx: 296 requests
- 5xx: 54 requests

## Endpoints
- GET /v1/events  (8420 requests, success 99.17%, p99 9.6 s)
- POST /v1/metrics  (5210 requests, success 99.04%, p99 9.6 s)
- GET /v1/releases  (3140 requests, success 97.13%, p99 9.6 s)
- POST /v1/crash  (1180 requests, success 88.14%, p99 9.6 s)
- GET /health  (640 requests, success 100.00%, p99 9.6 s)
```

The event list (`EventListExport`):
```
# Scout Events
4 events

- 2026-07-08T15:03:56Z  app_launch
- 2026-07-08T14:33:56Z  screen_view
- 2026-07-08T14:03:56Z  button_tap
- 2026-07-08T13:33:56Z  purchase
```

A single crash, with its stack trace fenced as a code block (`CrashExport`):
````
# Scout Crash — NSRangeException
2026-07-08T15:03:56Z

Reason: -[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]

## Stack Trace
```
0   CoreFoundation        0x0 __exceptionPreprocess + 164
1   libobjc.A.dylib       0x0 objc_exception_throw + 60
2   CoreFoundation        0x0 -[__NSArrayM objectAtIndex:] + 1228
3   Scout                 0x0 FeedViewController.row(at:) + 88
```
````

A crash issue grouping several occurrences by fingerprint (`CrashGroupExport`):
```
# Scout Crash Issue — NSRangeException
2 occurrences · 1 device · 1 session
First seen 2026-07-08 13:03 · Last seen 2026-07-08 14:03

Reason: index beyond bounds

Top frame: 2 Scout 0xdef objectAtIndex + 99

## Occurrences
- 2026-07-08T14:03:56Z  (device 30d04c2a, session 3912cbd3)
- 2026-07-08T13:03:56Z  (device 30d04c2a, session 3912cbd3)
```

Hangs mirror crashes, with a duration alongside each occurrence (`HangExport`, `HangGroupExport`):
````
# Scout Hang — Main Thread Blocked
2026-07-08T15:03:56Z

Duration: 6.4s

Reason: -[NSJSONSerialization dataWithJSONObject:options:error:] on main thread

## Stack Trace
```
0   Foundation            0x0 -[NSJSONSerialization dataWithJSONObject:options:error:] + 208
1   Scout                 0x0 FeedViewController.reload(with:) + 152
2   UIKitCore             0x0 -[UIViewController viewWillAppear:] + 88
3   UIKitCore             0x0 -[UINavigationController _startTransition] + 1024
```
````
```
# Scout Hang Issue — Image Layout Pass
2 occurrences · 1 device · 1 session
First seen 2026-07-08 13:03 · Last seen 2026-07-08 14:03

Max duration: 9.8s

Top frame: 2 Scout 0xdef layout + 99

## Occurrences
- 2026-07-08T14:03:56Z  9.8s  (device 30d04c2a, session 3912cbd3)
- 2026-07-08T13:03:56Z  4.2s  (device 30d04c2a, session 3912cbd3)
```

The device timeline (`TimelineExport`) nests installs, launches, and sessions as headings, with events and crashes as chronological bullet rows under each session:
```
# Scout Timeline — Device aaaaaaaa
1 install · 1 launch · 1 session · 2 events · 1 crash

## Install 2023-11-14 (bbbbbbbb)

### Launch 2023-11-14 22:13 (cccccccc)

#### Session 2023-11-14 22:14–22:20 (dddddddd)
- 2023-11-14T22:14:00Z  app_open
- 2023-11-14T22:15:00Z  ⚠️ crash: EXC_BAD_ACCESS
- 2023-11-14T22:16:00Z  purchase_completed
```

All of these are built from a shared `ExportLine` model (`.heading`, `.text`, `.bullet`, `.code`, `.blank`) rather than hand-assembled strings, so the Markdown syntax lives in one place ([ExportLine.swift](../Sources/Scout/UI/Timeline/Export/ExportLine.swift)).
