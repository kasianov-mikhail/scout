//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

package struct SeriesKey: Hashable, Comparable, Sendable {
    package let name: String
    package let category: String?
    package let version: String?

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
    package var key: SeriesKey {
        SeriesKey(name: name, category: category, version: version)
    }
}
