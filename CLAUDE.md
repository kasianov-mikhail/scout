# Maintaining these instructions

- When you notice recurring feedback or a new convention that isn't captured yet, proactively propose adding it as a rule — surface it as a suggested edit for the user to approve rather than editing on your own initiative. General Swift style, code organization and structure rules go to the shared user-level rule `~/.claude/rules/swift-style.md` (loaded automatically for Swift files in scout, scout-db, scout-server and scout-ip); only Scout-specific conventions go here.

# Scout conventions

## UI strings

- Scout UI strings must always render in source English: use `Text(verbatim: …)` for literals (or `.navigationTitle(en: …)` for titles) so they don't resolve through the host app's `LocalizedStringKey` catalog.

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

## README screenshots

- The six dashboard screens (`home`, `event`, `retention`, `crash`, `metric_distribution`, `release_health`) appear in light and dark. Each is a `<picture>` with a `prefers-color-scheme: dark` `<source>` and a light `<img>`. The PNGs are uploaded to GitHub (`user-attachments`), not stored in the repository, so the README links their URLs. Keep the 1206 × 2622 simulator originals outside the repo.
- GitHub strips `style` from README HTML, so the frame is baked into the PNG. Never wrap screenshots in a table: its cell border and about 13 px of padding shrink the screen.
- Frame: no shadow and no transparent margin. Scale to 960 px wide (4 px per CSS px for the 240 px display width, so 960 × 2087), clip to a rounded rectangle with a 24 px radius (6 CSS px, the GitHub box radius), then stroke a 4 px border (1 CSS px) inset so it lies inside the image. Use sRGB and high-quality interpolation.
- Border color is GitHub's muted divider, drawn opaque: `#dfe4e9` in light (`#d1d9e0` at 70 % over white) and `#2f353d` in dark (`#3d444d` at 70 % over `#0d1117`). The default border color, `#d1d9e0` / `#3d444d`, looked heavier than the heading dividers.
- Compression: `pngquant --quality 85-100 --speed 1 --strip --force`. The 8-bit palette keeps the alpha of the rounded corners and brings each file to about 60–100 KB, down from about 300 KB.
- Spacing: each row of three is its own `<p>` with no whitespace between the `<picture>` elements, joined by `&emsp;&emsp;&ensp;`. That is 2.5 em, about 40 px at the 16 px README font, the same as the gap between columns on the GitHub dashboard. Every `<img>` has `width="240"`. Three pictures and two gaps take 800 px, which fits the 838 px README column; a narrower view wraps the third picture. The vertical gap is the paragraph margin (16 px) plus about 6 px under an inline image, and cannot be changed without CSS.
- Upload: drop the PNGs into a comment on the PR to get their URLs, then compare each downloaded file with the local one (`cmp`) before putting the URL in the README. Open the README at the commit hash, not the branch, to check the render, because GitHub caches the branch page.
