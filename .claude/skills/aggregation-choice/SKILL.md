---
name: aggregation-choice
description: Decide whether a Scout dashboard read should use a pre-aggregated source (a scout-db aggregate in the Native catalog, or a scout-server endpoint for Hosted) or stay a raw record read, and show the gain or loss of that choice at 1k, 10k and 100k DAU while the feature is planned, written and reviewed. Use when adding or changing a dashboard screen or provider, a Native or Hosted read, a catalog aggregate (`CatalogEntry+Entries.swift`, `CatalogEntry+Metrics.swift`), the record cache, or a scout-server metrics endpoint.
---

The "Aggregated reads" rules in `.claude/CLAUDE.md` say what is allowed. This skill says when an aggregate is worth its cost. An aggregate is not free. It moves cost from the read on one dashboard to the write on every user device.

Decide by the read. Check the write. One aggregate costs about three background requests per synced batch, and the user does not see them. The write matters only because it adds up: every aggregate on an entity adds its own slots to every batch, a shared key makes all devices write the same vector, and an aggregate nobody reads is pure write cost.

Show the gain or the loss while the work happens, not only at the end. Every plan, every PR description and every review of a read that this skill covers carries the impact table from "Impact table" below. A read without the table is not planned, and a PR without it is not ready.

## Variables

| Name | Meaning |
|---|---|
| `READ` | The read under review: the screen, the provider, and the backend call. |
| `RANGE_WEEKS` | Weeks in the requested range. `trailingYear` is 53. |
| `RECORDS` | Raw records the read would scan over the range. |
| `GROUPS` | Distinct values of the group key that are active in one week. |
| `VECTORS` | Vector records an aggregate read fetches: about `GROUPS × RANGE_WEEKS`, but never more than `RECORDS`. |
| `PARTS` | `parts:` of the aggregate. The index costs `RANGE_WEEKS × PARTS` index records. |
| `DENSITY` | `RECORDS / VECTORS`: raw records folded into one vector. |
| `WRITES` | Records per day that the entity syncs from all devices. |
| `TIERS` | The three audiences every estimate is given for: 1k, 10k and 100k DAU. |
| `RATIO` | Time before the change divided by time after it, per tier. Above 1 is faster, below 1 is slower. |

## Audience tiers

Give every estimate for all three tiers. One tier hides how a read scales.

| Tier | What it stands for |
|---|---|
| 1k DAU | A typical indie app. Heavy screens take 10–30 s before aggregation. |
| 10k DAU | The timeout and jetsam line. Some screens do not open at all before aggregation. |
| 100k DAU | The line past which every read keyed by an ID stops working, even after aggregation. |

Per tier: 2 sessions per device per day, 30 events per session, WAU of about 2.5 × DAU, and 5k crashes per year at 1k DAU, scaled linearly. Above 10k DAU CloudKit throttles, so the "before" times are a lower bound.

How `RATIO` behaves tells the class of the read:

| `RATIO` across tiers | Meaning |
|---|---|
| Grows about 10× per tier | After the change the cost no longer depends on the audience. A bounded key. |
| Constant | Both sides grow with the audience. A key by ID, a page, or parallelism. The screen still hits a ceiling. |
| Constant and independent of DAU | The cost depends on names, versions or weeks, not on users. |
| Below 1 | The change made the read slower. Say for how long, for example the transition year before `since`. A small loss that ends by itself is minor; see the rule under "Impact table". |

## Cost model

Native, scout-db 0.4.0:

| Operation | Cost |
|---|---|
| Raw read | `RECORDS / 400` pages, one after another, about 300 ms each. |
| Aggregate read | 1 head record, `RANGE_WEEKS × PARTS` index records, then `VECTORS` fetched by ID in batches of 400, up to 8 batches at once. |
| Aggregate write | For every aggregate on the entity, each synced batch loads and saves one vector per touched (group, week). It also writes index pages for new slots. Saves use `saveIfUnchanged`, so shared vectors cause conflicts and retries. Every device pays this, even if no one opens the screen. |
| New aggregate on a published entity | Reads before `since` run `RecordFold`: a raw scan of `[lower, since)` on every call, for each aggregate, with nothing saved. This lasts until the range no longer reaches before `since`, up to a year. |
| Derived key | Records written before the key existed fold into the group `""`. |
| Cell | One number. There is no distinct count and no last value. `min` and `max` cannot be undone when a record changes. |

Hosted:

| Operation | Cost |
|---|---|
| Raw read | `POST /records/query`, about 150 ms per page. |
| Aggregate | The server computes it from raw rows on each request. There are no rollup tables. One call is about 100 ms only while the scanned rows stay small and an index covers the filter. |

## Steps

1. Find what bounds `READ`.
   - It is bounded by one device, session, install, incident, or one feed page: keep the raw read and stop.
   - It is bounded only by a date range, or by nothing: continue.
2. Count `RECORDS`, `GROUPS`, `VECTORS` and `DENSITY` for each tier in `TIERS`.
3. Price the read both ways with the cost model, for each tier.
   - Compare the raw pages with the head, the index and the vector batches.
   - Compute `RATIO` per tier, for the cold open of the screen.
   - During a transition (`RecordFold`, chunked loads), compute `RATIO` for the transition period and after it.
4. Decide from the read: is there a screen that reads the aggregate, and is the key bounded? The tables below give the cases.
5. Check the write. It is a check, not a factor in the decision. It blocks an aggregate in three cases.
   - **Too many on one entity.** Count the aggregates the entity already has. Each one adds slots to every synced batch: two aggregates cost about ×3 on the write, six about ×7. Session has 4 and the metrics have 2.
   - **A shared key under load.** Name, category, version and series key are vectors that every device writes. At 10k DAU a popular vector is saved thousands of times an hour, `saveIfUnchanged` retries with a backoff of up to 2 s, and a sync grows from a second to several. A key private to one device, such as `device_id`, has no conflicts.
   - **No reader.** An aggregate that no screen reads must not be added, and must be removed when its last reader goes away.
   - Weigh the check by `WRITES`: Event and the metrics are hot, Crash and Visit are not.
6. Check the transition.
   - Is the entity already published? Then `RecordFold` runs on every read for up to a year.
   - Is the key derived? Then old records land in the group `""`.
7. For Hosted, check the server side.
   - The endpoint must not scan the whole history.
   - An index must cover every filter. For example, `uuid IN` needs an index on `(record_type, uuid)`.

## Impact table

The table compares the read with aggregation on and off, per tier. It is the same table whether the aggregate is being added, changed or removed.

| Column | Content |
|---|---|
| Read | The screen and the call, one row per read the change touches. |
| 1k / 10k / 100k DAU | `RATIO` per tier: the time with aggregation off divided by the time with it on, for a cold open. Above 1 is a gain, below 1 is a loss. |
| Transition | `RATIO` for the transition period when it differs: the year before `since` passes, or a chunked cold load. |
| Class | Bounded key, key by ID, page, parallelism, or write-only. Read it from the `RATIO` pattern in "Audience tiers". |

```
| Read | 1k DAU | 10k DAU | 100k DAU | Transition | Class |
|---|---|---|---|---|---|
| Activity, cold open | 23 | 230 | 2300 | — | bounded key |
| Devices, cold open | 8 | 8 | 8 | — | key by ID, ceiling near 30k DAU |
| Crashes list, cold open | 1 | 1 | 1 | 0.2 / 0.03 / 0.003 | tallies without a cache |
| IntMetric `.max`, any read | 1 | 1 | 1 | — | write-only, remove |
```

When the table appears:

| Moment | What the table shows |
|---|---|
| Plan, before code | Both designs for each read. Pick the design with the larger ratios, and name the ceiling of a key by ID. |
| During the work | The table of the chosen design. Update it when the read changes, for example when a filter or a cache is added. |
| PR description | The final table in three to four lines, under the PR rules. A significant loss is a risk the reviewer must know, so state how long it lasts. |
| Review | The table for the diff. Flag a significant loss and a write-only row. |

A loss below 1 is significant only in one of these cases. Otherwise list the row, mark it "minor", and do not open a fix for it.

- The ratio is below 0.5 on any tier.
- The loss has no end date. A transition that ends by itself is not this case.
- The screen was usable before, under about 10 s, and the loss pushes it past that. A screen that was already unusable before, such as a raw scan of hours, does not become worse in any way the user sees.
- The change is on a shared ScoutUI path and makes Hosted slower.

Example: a transition ratio of 0.75 to 0.8 that ends when `since` passes is minor, and the gain after it is what counts.

Rules for the cells:

- The time with aggregation off is the raw read of the same records with the same filters. For a published entity with no history before `since`, both sides cost the same, so the ratio is 1.
- A removed aggregate flips the sides: the ratio is the time with the aggregate divided by the time without it. A write-only aggregate gives 1 on every read, and its row says "remove".
- Round to two significant digits. Keep the ratios, not the percentages, in the table.
- Give a range, not one number, when the ratio depends on the app's profile rather than on DAU. Examples: the share of meter samples among double metrics, the number of timers per session, the number of event names or fingerprints. Write the range for a light and a heavy profile, such as `0.1–0.9`, and name the profile value that moves it.
- Mark a ratio that comes from a measurement, such as a call count from a test harness, and keep it apart from a modeled one. A modeled ratio counts records only; when several calls run one after another, say that the latency between them is not included.
- A ratio that is equal across the tiers is expected when both sides grow linearly with DAU. Do not read it as a measured constant: the profile value behind it still varies between apps.
- Below the table, give the pages, vectors and seconds behind each ratio, once.

## Aggregate when

| Case | Why | Example |
|---|---|---|
| The result is a chart, count, readout or index over a range, and `RECORDS` grows with events, sessions or installs. | The raw read grows every day the app is live. | Event counts by name. |
| The group key has low cardinality and `DENSITY` is 5 or more. | One vector replaces many records. | Name, app version, category, lifecycle key, metric series key. |
| A distinct count can be rewritten as a count of a bounded key that the device stamps. | Groups stay bounded at any DAU. | `visit_gap` for DAU, WAU and MAU. Retention marks per cohort. |
| The screen opens often, or it gates Home. | The read cost repeats on every open. | Releases, Retention, Activity. |

## Stay raw, or change the design, when

| Case | Why | Example |
|---|---|---|
| The read is bounded by one device, session, install, incident or feed page. | It does not grow with the audience. | Session timeline, incident detail. |
| The group key is per device, per install, per fingerprint, or per record, and `DENSITY` is about 1. | `VECTORS` is about `RECORDS`. The read does not get cheaper, and every write pays more. | Crash count by `device_id`. |
| The group key is an ID and the goal is a distinct count across time. | Cost is WAU × weeks. It is an aggregate in name only. | Session series by `device_id` for DAU. Use a bounded stamped key instead, or ask about a scout-db feature. |
| No screen reads the aggregate. | It is pure write cost on every device. | `.max` on every metric series when only Meter needs it. Session `install_id` after Retention moved to marks. |
| The range is short and the data is small. | Head and index overhead can exceed one or two raw pages. | A 14-day chart of a small version. Do not add an aggregate only for this. |
| The aggregate kind does not exist. | `max` is not the last value, and a sum is not a distinct count. | Meter last value. Ask the user before changing the meaning of a chart. |

## Related traps

- Do not split one Hosted call into chunks. The server may scan the whole history on each call.
- Split a Native cold load only when a load is often interrupted. Fetch the chunks oldest first and keep them contiguous for `RecordCache.store`.
- Cache aggregate reads by frozen weeks. An uncached aggregate on a published entity repeats `RecordFold` on every open.
- One read per range is enough. Share it when several names filter the same vectors on the client.
- Before a release tag, an aggregate can still be removed. After a tag, catalog changes must stay additive, because other SDK versions compare the schema for equality.
- Ask before you change scout-db or create a scout-db tag.

## If a step fails

- The volume is unknown: use the assumptions in step 2 and say that the numbers are estimates.
- The read and write costs are close: keep the current design. Note the open question in the plan or the review.
- The decision needs a scout-db feature or a scout-server contract change: stop and ask the user.

## Final report

- `READ`, its bound, and the decision: aggregate, raw, or redesign.
- The impact table from "Impact table", with the pages, vectors, seconds and peak memory behind each ratio below it.
- The write check: the number of aggregates on the entity after the change, whether the key is shared, and whether a reader exists.
- The transition cost: `RecordFold` and the empty derived group, with a `RATIO` for the transition period when it is below 1, marked significant or minor.
- The speed gain for the chosen tier as `(1 / (1 − saved) − 1) × 100%` with the multiplier, when the user's rules ask for it.
- A line that the numbers are estimates, not measurements, and that the "before" times above 10k DAU are a lower bound because of throttling.
