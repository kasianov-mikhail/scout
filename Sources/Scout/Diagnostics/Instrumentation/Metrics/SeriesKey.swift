//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct SeriesKey: Hashable, Comparable, Sendable {
    let name: String
    let category: String?
    let version: String?

    package init(name: String, category: String?, version: String?) {
        self.name = name
        self.category = category
        self.version = version
    }

    package static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.name, lhs.category ?? "", lhs.version ?? "") < (rhs.name, rhs.category ?? "", rhs.version ?? "")
    }
}

extension MetricSeries {
    package init(key: SeriesKey, points: [MetricSeriesPoint]) {
        self.init(name: key.name, category: key.category, version: key.version, points: points)
    }

    package var key: SeriesKey {
        SeriesKey(name: name, category: category, version: version)
    }
}
