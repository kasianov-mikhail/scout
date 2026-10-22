---
name: aggregation-choice
description: Decide whether a Scout dashboard read should use a pre-aggregated source (a scout-db aggregate in the Native catalog, or a scout-server endpoint for Hosted) or stay a raw record read, and price both sides, including the write cost on user devices. Use when planning, reviewing, or changing a Native or Hosted read, a catalog aggregate (`CatalogEntry+Entries.swift`, `CatalogEntry+Metrics.swift`), the record cache, or a scout-server metrics endpoint.
---

The "Aggregated reads" rules in `.claude/CLAUDE.md` say what is allowed. This skill says when an aggregate is worth its cost. An aggregate is not free. It moves cost from the read on one dashboard to the write on every user device.

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
2. Count `RECORDS`, `GROUPS`, `VECTORS` and `DENSITY` at 1k DAU and at 10k DAU.
   - Use 2 sessions per device per day, 30 events per session, 5k crashes per year, and WAU of about 2.5 × DAU.
3. Price the read both ways with the cost model.
   - Compare the raw pages with the head, the index and the vector batches.
4. Price the write side of a new aggregate.
   - Take `WRITES` and the number of aggregates already on the entity.
   - Count the extra vectors per synced batch.
   - Note whether the key is shared by all devices, which means conflicts, or private to one device.
5. Check the transition.
   - Is the entity already published? Then `RecordFold` runs on every read for up to a year.
   - Is the key derived? Then old records land in the group `""`.
6. Decide with the tables below.
7. For Hosted, check the server side.
   - The endpoint must not scan the whole history.
   - An index must cover every filter. For example, `uuid IN` needs an index on `(record_type, uuid)`.

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
- The read cost both ways at 1k and 10k DAU: pages, vectors, and time.
- The write cost: extra vectors per synced batch, and whether the key is shared.
- The transition cost: `RecordFold` and the empty derived group.
- The speed gain as `(1 / (1 − saved) − 1) × 100%` with the multiplier, and the memory change when it differs.
- A line that the numbers are estimates, not measurements.
