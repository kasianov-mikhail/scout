# Exports

Every list and detail screen in the dashboard — devices, network requests, events, the crash and hang timeline, and incident groups — has a share button that renders its data as a Markdown document instead of a screenshot, so it pastes cleanly into an issue or a chat. All of them are built from the same shared `ExportLine` model (`.heading`, `.text`, `.bullet`, `.code`, `.blank`) rather than hand-assembled strings, so the Markdown syntax lives in one place ([ExportLine.swift](../Sources/Scout/UI/Timeline/Export/ExportLine.swift)) and every screen produces the same shape of document.

Here's a single crash export (`CrashExport`) as a representative example — a title heading, plain summary lines, a second-level heading, and the stack trace fenced as a code block. The date below is illustrative:
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

List-style exports — devices, network endpoints, events, incident occurrences, and the device timeline — follow the same shape, with each row rendered as a bullet (`- ...`) instead of a fenced block.
