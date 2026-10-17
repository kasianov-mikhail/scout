//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct MetricSeries: Decodable, Sendable {
    package let name: String
    package let category: String?
    package let version: String?
    package let points: [MetricSeriesPoint]

    package init(name: String, category: String?, version: String? = nil, points: [MetricSeriesPoint]) {
        self.name = name
        self.category = category
        self.version = version
        self.points = points
    }
}
