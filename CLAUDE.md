When pushing new commits to an existing PR, update its title and description to reflect the full scope of changes.

Multi-line doc comments (`///`) must end with a trailing empty `///` line. Single-line doc comments do not need this.

Never remove or rename fields, record types, or index modifiers (`QUERYABLE`/`SEARCHABLE`/`SORTABLE`) in the CloudKit `Schema` file — Production schemas are append-only and `cktool import-schema` will reject removals with `cannot remove field … which exists in active production type …`. To deprecate a field, stop writing it in code but keep its declaration in `Schema`.

Scout UI strings must always render in source English: use `Text(verbatim: …)` for literals (or `.navigationTitle(en: …)` for titles) so they don't resolve through the host app's `LocalizedStringKey` catalog.
