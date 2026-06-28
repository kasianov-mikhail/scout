# Maintaining these instructions

- When you notice recurring feedback or a new project convention that isn't captured here yet, proactively propose adding it as a rule to this file — surface it as a suggested edit for the user to approve rather than editing on your own initiative.

# Git & pull requests

## Pull requests

- When pushing new commits to an existing PR, update its title and description to reflect the full scope of changes.

## Commits

- Always create commits using the repository's git `user.name`/`user.email` identity.
- Never set the author or committer to "Claude <noreply@anthropic.com>" or any other bot identity, and do not add "Co-Authored-By" trailers.

# Project structure

- Keep an eye on the folder and file structure as the codebase evolves, and reorganize it when needed: when a folder accumulates too many files at one level, group related files into subfolders following the conventions already present nearby (e.g. `UI/Chart` groups files into `Model`, `Scale`, `View`, `Comparison`, `Picker`, `Range`).
- Move files as-is without code changes, and ship structure-only reorganizations as their own PR, separate from functional changes.
- When a type or protocol is used in essentially one place, keep it next to that use site rather than in a neutral/shared folder. Broadly-used protocols (e.g. the `Record*` family in `RecordProtocols.swift`) still belong in a shared grouping.
- The `Tests/ScoutTests` tree mirrors `Sources/Scout`, so whenever you move or regroup source folders, apply the same move to the matching test folders in the same PR — don't leave the test layout behind.

# Code organization

- Minimize code duplication.
- Extract logic and computations out of SwiftUI views into separate types covered by unit tests.
- Keep views from bloating: when a view accumulates non-trivial logic, computations, or repeated layout, extract them into model types or subviews.

# Building & testing

- When a change touches a declaration the tests reference (renaming or re-typing a function/initializer/property, changing a signature, or moving a symbol), build the test target locally with `build-for-testing`, not just the app target — building the app alone misses test-only call sites and lets the breakage surface in CI instead.

# Swift code style

## Comments

- Don't add comments. The only allowed comments are doc comments (`///`) on public API (see below) and rare inline `//` notes that explain something genuinely critical and non-obvious (a subtle "why", a non-obvious invariant, a workaround). Never add comments that restate what the code already says.

## Doc comments

- Document only public API: write doc comments (`///`) for `public`/`open` declarations only, and leave `internal`, `private`, and `fileprivate` declarations undocumented (an inline `//` note for genuinely non-obvious logic is still fine).
- Multi-line doc comments (`///`) must end with a trailing empty `///` line, except when they document a single-line property declaration (a stored `let`/`var` written on one line), where the trailing empty `///` is omitted. Single-line doc comments never need it.

## `MARK` comments

- Don't use `// MARK:` comments to divide code into sections.

## `guard` statements

- A short, single-condition `guard` stays fully inline — both simple bindings (`guard let x = y else { return }`, `guard !x else { return }`) and pattern matching (`guard case .x = y else { return nil }`).
- Expand the `else` block onto multiple lines (`else {` / body / `}`) when the `guard` has multiple conditions, or when its condition or `else` body is long or complex. Multi-condition guards still keep their conditions on a single line.

## Function and method signatures

- Function/method **signatures** (declarations) should be written on a single line, even with many parameters or default values — do not wrap parameters onto separate lines.
- This applies to declarations only, not to call sites: a function or initializer **call** with several arguments wraps each argument onto its own line.

# Design

- When planning visual design (layout proportions, spacing, sizing of UI elements), prefer the golden ratio (≈1.618) for proportions where a ratio choice is otherwise arbitrary.

# Scout conventions

## UI strings

- Scout UI strings must always render in source English: use `Text(verbatim: …)` for literals (or `.navigationTitle(en: …)` for titles) so they don't resolve through the host app's `LocalizedStringKey` catalog.

## Sample data

- Sample data in app code is named `sample` (a `static var` for fixed instances, a `static func sample(...)` when parameters are needed), placed in an extension at the end of the type's main file (e.g. `Device.swift`), and built directly via the struct initializer.
- A collection of sample instances is named `samples` (plural) — e.g. `static let samples: [Release]`.
- Tests use a different naming convention — `make<Name>(...)` factory functions.

## Core Data migrations

- Never reset, wipe, or destroy the persistent store to recover from a model mismatch — user data must survive schema changes.
- Every schema change ships as a new model version in `Scout.xcdatamodeld` (old versions are kept), relying on lightweight migration where the change is inferable; otherwise add a mapping model (`.xcmappingmodel`) and an `NSEntityMigrationPolicy` if needed.
- Core Data cannot migrate a store down to an older model, so prefer additive, backward-compatible changes (new optional attributes, new entities) when feasible — that is the only practical form of a reverse migration.

## CloudKit schema

- Never remove or rename fields, record types, or index modifiers (`QUERYABLE`/`SEARCHABLE`/`SORTABLE`) in the CloudKit `Schema` file — Production schemas are append-only and `cktool import-schema` will reject removals with `cannot remove field … which exists in active production type …`.
- To deprecate a field, stop writing it in code but keep its declaration in `Schema`.

## Server contract

- scout and scout-server (`kasianov-mikhail/scout-server`) share an HTTP wire-format contract, so changes to the two repos are often interrelated: a change to request/response shapes, field names, the queryable-field set, or endpoints on the scout side (the `Core/Database/Backend` layer — `HTTPQueryCoding`, `HTTPRecordCoding`, `HTTPDatabase`) usually needs a matching change in scout-server, and vice versa.
- They are separate repos, so a contract change normally ships as a PR in each — call out the companion PR in both descriptions.
- `ServerContractTests` (run by the `Server` workflow in `.github/workflows/server.yml`, which boots a real scout-server) guards the wire format, so extend and run it when you touch either side rather than assuming the contract still holds.
