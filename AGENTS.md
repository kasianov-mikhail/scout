# Scout conventions

## UI strings

- Scout UI strings must always render in source English: use `Text(verbatim: …)` for literals (or `.navigationTitle(en: …)` for titles) so they don't resolve through the host app's `LocalizedStringKey` catalog.

## Dynamic Type

- All Scout UI renders at a fixed text size and does not support Dynamic Type. `HomeView` pins it with `.dynamicTypeSize(.large)` at the root. The single public entry point `scoutHome(isPresented:backends:)` presents `HomeView`.
- Keep this cap. A new public view or entry point that does not go through `HomeView` gets the same cap.
- Do not propose Dynamic Type support or removing the cap in plans, reviews, or audits.

## Lists

- Use only `.listStyle(.plain)` for `List`s; section titles are `Header(title:)` rows (not `Section` headers/footers), with `.listRowSeparator(.hidden)` on non-row content.

## Initializer assignments

- In an initializer, if at least one property assignment needs `self.` (a parameter or local shadows the property), prefix every property assignment with `self.` for consistency; if none needs it, omit `self.` from all of them.

## Provider naming

- A view with a single `@StateObject` provider names it `provider` (e.g. `@StateObject var provider = StatProvider(eventName: "Session")`), regardless of the concrete provider type.
- A view with more than one `@StateObject` provider gives each a descriptive name reflecting what it represents (e.g. `activities`, `sessions`, `crashes`, `releases`, `logs`).

## Sample data

- A single instance is `sample` (`static var`, or `static func sample(...)` when parameterized); a collection is `samples` (`static var`/`let [Type]`) — both built directly via the initializer.
- Types with `samples` conform to `Fixture` (`Sources/Scout/UI/Database/Fixture.swift`), whose single generic bridge supplies `[Type].samples` and bare `.samples` for every conformer — independent of `RecordDecodable`.
- A type with more than one sample helper groups them in one `extension Type: Fixture { ... }` in `Type+Fixture.swift` next to the type's main file (e.g. `Device+Fixture.swift`); a type with only `samples` keeps it in the main file.
- Providers/view models don't expose `fixture()`. A `#Preview` builds the provider directly and sets its published state inline, e.g. `provider.result = .success([ReleaseHealth].samples)`; if priming needs control flow, wrap it in a local `@MainActor func` (`#Preview`'s `@ViewBuilder` body rejects a bare loop) and call that in a `let`.
- Tests use `make<Name>(...)` instead.

## Core Data migrations

- Never reset, wipe, or destroy the persistent store to recover from a model mismatch — user data must survive schema changes.
- Every schema change ships as a new model version in `Scout.xcdatamodeld` (old versions are kept), relying on lightweight migration where the change is inferable; otherwise add a mapping model (`.xcmappingmodel`) and an `NSEntityMigrationPolicy` if needed.
- Core Data cannot migrate a store down to an older model, so prefer additive, backward-compatible changes (new optional attributes, new entities) when feasible — that is the only practical form of a reverse migration.

## Server contract

- scout and scout-server (`kasianov-mikhail/scout-server`) share an HTTP wire-format contract, so changes to the two repos are often interrelated: a change to request/response shapes, field names, the queryable-field set, or endpoints on the scout side (the `Core/Database/Backend` layer — `HTTPQueryCoding`, `HTTPRecordCoding`, `HTTPDatabase`) usually needs a matching change in scout-server, and vice versa.
- They are separate repos, so a contract change normally ships as a PR in each — link the matching PR in the other repo from both descriptions.
- `ServerContractTests` (run by the `Server` workflow in `.github/workflows/server.yml`, which boots a real scout-server) guards the wire format, so extend and run it when you touch either side rather than assuming the contract still holds.

## Aggregated reads

- Dashboard charts, readouts, counts and search indexes read pre-aggregated data, never a page-by-page scan of raw records over a date range.
  - Native: declare a scout-db aggregate in the catalog (`CatalogEntry+Entries.swift`) and read it with `store.query(...).series(...)`.
  - Hosted: compute it on the server behind `GET /metrics/series` or a dedicated endpoint (a contract change — see "Server contract"). Don't reintroduce grid/matrix records.
- Don't add a new `store.records(...)` or `datedIDs(...)` (Native) or `readAll(...)` (ScoutUI) over a date range to build an aggregate on the client. Raw reads are fine only when something else bounds them: one device, session or install, one page of a paginated feed, or one incident's detail.
- Never widen a raw scan to `.distantPast` or the whole history; such reads grow every day the app is live.
- An aggregate added to an already published entity starts at the next hour (`since`); scout-db folds older records with `RecordFold`, so no backfill is needed. A derived key (`derive:`) is absent on records written before it existed — handle the empty group.
- A catalog change republishes the CloudKit schema; clients on other SDK versions compare it for equality (`CatalogEntry+Publish.swift`), so check that the change is additive.
- If an aggregate needs a new scout-db feature, ask before changing scout-db or creating a scout-db tag.
- In a plan or review, flag any read whose cost grows with the number of events, sessions or installs, and estimate it at a realistic audience (e.g. 1k DAU, 400 records per CloudKit page).

## Release names

- A GitHub release title is `X.Y.Z — Theme`. The theme names the headline change in 12 characters or fewer, so the release sidebar does not truncate it.
- The theme is a noun or a short noun phrase: no "and", no verbs, no lists. Every other change goes to the release notes.
- A breaking change does not go into the title. Mark it with **Breaking:** in the release notes.

```
✗ 0.4.0 — MetricKit diagnostics and on-device symbolication
✓ 0.4.0 — MetricKit
```
