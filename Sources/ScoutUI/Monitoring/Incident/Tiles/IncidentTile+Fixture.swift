//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension IncidentTile where Element == Crash {
    static var samples: [IncidentTile<Crash>] {
        tiles(
            records: [Crash].samples,
            keys: [:],
            current: nil,
            previous: nil,
            range: IncidentRange.week.range(now: Date())
        )
        .map { tile in
            tile.replacing(previous: tile.count > 3 ? tile.count - 2 : 0)
        }
    }
}

extension IncidentTile where Element == Hang {
    static var samples: [IncidentTile<Hang>] {
        tiles(
            records: [Hang].samples,
            keys: [:],
            current: nil,
            previous: nil,
            range: IncidentRange.week.range(now: Date())
        )
        .map { tile in
            tile.replacing(previous: tile.count > 3 ? tile.count - 2 : 0)
        }
    }
}

extension IncidentTile where Element == ResourceException {
    static var samples: [IncidentTile<ResourceException>] {
        tiles(
            records: [ResourceException].samples,
            keys: [:],
            current: nil,
            previous: nil,
            range: IncidentRange.week.range(now: Date())
        )
    }
}

extension IncidentTile {
    fileprivate func replacing(previous: Int) -> IncidentTile {
        IncidentTile(
            tally: tally,
            records: records,
            symbol: symbol,
            previous: previous,
            range: range
        )
    }
}
