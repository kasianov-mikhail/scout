//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Loading phase of a paginated, incrementally-fetched data source:
/// `idle` (ready to fetch the next page), `loading` (a fetch is in flight),
/// `exhausted` (no further pages remain).
///
enum Pagination {
    case idle
    case loading
    case exhausted
}
