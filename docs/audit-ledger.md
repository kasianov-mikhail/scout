# Lifecycle/sync audit ledger

## Accepted (conscious decision, won't fix)

## Tracked in issues

| Date | Issue | Severity | Summary |
|------|-------|----------|---------|
| 2026-04-27 | [#461](https://github.com/kasianov-mikhail/scout/issues/461) | HIGH | `SyncCoordinator.upload(snapshot:retry:)`: silent data loss when `serverRecordChanged` lacks `CKRecordChangedErrorServerRecordKey`; unbounded retry loop on sustained conflict |
| 2026-04-27 | [#462](https://github.com/kasianov-mikhail/scout/issues/462) | MEDIUM | Signal handler calls async-signal-unsafe Foundation APIs (`DispatchQueue.sync`, malloc, `JSONEncoder`, `FileManager`) — deadlock risk |
| 2026-04-27 | [#463](https://github.com/kasianov-mikhail/scout/issues/463) | MEDIUM | `VersionObject.launches()` force-unwraps `@NSManaged var appVersion: String?` — crash when `appVersion` is nil |
| 2026-04-27 | [#464](https://github.com/kasianov-mikhail/scout/issues/464) | LOW | Digest: `ActionTable` Task errors silently discarded; `SyncCoordinator` reset path may insert duplicate CloudKit matrix record |

## Fixed (historical reference)
