# Git & pull requests

When pushing new commits to an existing PR, update its title and description to reflect the full scope of changes.

Always create commits using the repository's git `user.name`/`user.email` identity. Never set the author or committer to "Claude <noreply@anthropic.com>" or any other bot identity, and do not add "Co-Authored-By" trailers.

# Swift code style

Multi-line doc comments (`///`) must end with a trailing empty `///` line, except when they document a single-line property declaration (a stored `let`/`var` written on one line), where the trailing empty `///` is omitted. Single-line doc comments never need it.

`guard` statements with multiple conditions or pattern matching (`case .x = y`) should keep the conditions on a single line but expand the `else` block to multiple lines (`else {` / body / `}`). Single-condition simple guards (`guard let x = y else { return }`, `guard !x else { return }`) stay fully inline.

Function/method **signatures** (declarations) should be written on a single line, even with many parameters or default values — do not wrap parameters onto separate lines. This applies to declarations only, not to call sites: a function or initializer **call** with several arguments wraps each argument onto its own line.

# Scout conventions

Scout UI strings must always render in source English: use `Text(verbatim: …)` for literals (or `.navigationTitle(en: …)` for titles) so they don't resolve through the host app's `LocalizedStringKey` catalog.

Sample data in app code is named `sample` (a `static var` for fixed instances, a `static func sample(...)` when parameters are needed), placed in an extension at the end of the type's main file (e.g. `Device.swift`), and built directly via the struct initializer. Tests use a different naming convention — `make<Name>(...)` factory functions.

# Core Data migrations

Never reset, wipe, or destroy the persistent store to recover from a model mismatch — user data must survive schema changes. Every schema change ships as a new model version in `Scout.xcdatamodeld` (old versions are kept), relying on lightweight migration where the change is inferable; otherwise add a mapping model (`.xcmappingmodel`) and an `NSEntityMigrationPolicy` if needed. Core Data cannot migrate a store down to an older model, so prefer additive, backward-compatible changes (new optional attributes, new entities) when feasible — that is the only practical form of a reverse migration.

# CloudKit schema

Never remove or rename fields, record types, or index modifiers (`QUERYABLE`/`SEARCHABLE`/`SORTABLE`) in the CloudKit `Schema` file — Production schemas are append-only and `cktool import-schema` will reject removals with `cannot remove field … which exists in active production type …`. To deprecate a field, stop writing it in code but keep its declaration in `Schema`.
