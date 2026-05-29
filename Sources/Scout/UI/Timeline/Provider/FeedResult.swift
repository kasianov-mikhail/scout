//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Combined load and pagination state of a paged feed.
enum FeedResult<Value> {
    /// Nothing loaded yet.
    case idle
    /// The initial fetch is in flight.
    case loading
    /// A value is available with more pages to fetch.
    case loaded(Value)
    /// A value is available and the next page is in flight.
    case paging(Value)
    /// A value is available and every page is loaded.
    case exhausted(Value)
    /// A fetch threw.
    case failure(Error)
}

extension FeedResult {
    var value: Value? {
        switch self {
        case .loaded(let value), .paging(let value), .exhausted(let value):
            value
        case .idle, .loading, .failure:
            nil
        }
    }
}
