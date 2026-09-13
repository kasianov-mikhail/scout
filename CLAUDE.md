# Maintaining these instructions

- When you notice recurring feedback or a new convention that isn't captured yet, proactively propose adding it as a rule — surface it as a suggested edit for the user to approve rather than editing on your own initiative. General Swift style, code organization and structure rules go to the shared user-level rule `~/.claude/rules/swift-style.md` (loaded automatically for Swift files in scout, scout-db, scout-server and scout-ip); only Scout-specific conventions go here.

# Scout conventions

## UI strings

- Scout UI strings must always render in source English: use `Text(verbatim: …)` for literals (or `.navigationTitle(en: …)` for titles) so they don't resolve through the host app's `LocalizedStringKey` catalog.

## Lists

- Use only `.listStyle(.plain)` for `List`s; section titles are `Header(title:)` rows (not `Section` headers/footers), with `.listRowSeparator(.hidden)` on non-row content.

## Provider naming

- A view with a single `@StateObject` provider names it `provider` (e.g. `@StateObject var provider = StatProvider(eventName: "Session")`), regardless of the concrete provider type.
- A view with more than one `@StateObject` provider gives each a descriptive name reflecting what it represents (e.g. `activities`, `sessions`, `crashes`, `releases`, `logs`).

## Sample data

- A single instance is `sample` (`static var`, or `static func sample(...)` when parameterized); a collection is `samples` (`static var`/`let [Type]`) — both built directly via the initializer.
- Types with `samples` conform to `Fixture` (`Sources/Scout/UI/Database/Fixture.swift`), whose single generic bridge supplies `[Type].samples` and bare `.samples` for every conformer — independent of `RecordDecodable`.
- A type with more than one sample helper groups them in one `extension Type: Fixture { ... }` in `Type+Fixture.swift` next to the type's main file (e.g. `Device+Fixture.swift`); a type with only `samples` keeps it in the main file.
- Providers/view models don't expose `fixture()`. A `#Preview` builds the provider directly and sets its published state inline, e.g. `provider.result = .success([ReleaseHealth].samples)`; if priming needs control flow, wrap it in a local `@MainActor func` (`#Preview`'s `@ViewBuilder` body rejects a bare loop) and call that in a `let`.
- Tests use `make<Name>(...)` instead.

## Snapshot tests

- Image snapshot suites live in the separate `ScoutSnapshotTests` target (`Tests/ScoutSnapshotTests`), never in `ScoutTests` — this keeps the SnapshotTesting dependency and the `__Snapshots__` baselines out of the mirrored test tree.
- Snapshot views through the shared `Snapshotting.scout(width:height:)` strategy, and gate every suite with `@Suite(.enabled(if: ViewSnapshot.isSupported))`: baselines are recorded on iOS 26, and CI legs on other iOS versions must skip rather than diff against them.
- Views under test must render deterministically. Relative-time labels resolve against `Date()`, so time-bearing fixtures use offsets from now placed mid-bucket (e.g. −150 s for "2m ago"), never fixed epoch dates.
- To re-record a baseline, delete its PNG under `__Snapshots__` and run the suite twice: the first run records and fails, the second verifies.
- Keep the suite a small curated set of deterministically rendering primitives, and keep baselines in plain git — no Git LFS while they stay lightweight (revisit at tens of MB).

## Core Data migrations

- Never reset, wipe, or destroy the persistent store to recover from a model mismatch — user data must survive schema changes.
- Every schema change ships as a new model version in `Scout.xcdatamodeld` (old versions are kept), relying on lightweight migration where the change is inferable; otherwise add a mapping model (`.xcmappingmodel`) and an `NSEntityMigrationPolicy` if needed.
- Core Data cannot migrate a store down to an older model, so prefer additive, backward-compatible changes (new optional attributes, new entities) when feasible — that is the only practical form of a reverse migration.

## Server contract

- scout and scout-server (`kasianov-mikhail/scout-server`) share an HTTP wire-format contract, so changes to the two repos are often interrelated: a change to request/response shapes, field names, the queryable-field set, or endpoints on the scout side (the `Core/Database/Backend` layer — `HTTPQueryCoding`, `HTTPRecordCoding`, `HTTPDatabase`) usually needs a matching change in scout-server, and vice versa.
- They are separate repos, so a contract change normally ships as a PR in each — link the matching PR in the other repo from both descriptions.
- `ServerContractTests` (run by the `Server` workflow in `.github/workflows/server.yml`, which boots a real scout-server) guards the wire format, so extend and run it when you touch either side rather than assuming the contract still holds.
