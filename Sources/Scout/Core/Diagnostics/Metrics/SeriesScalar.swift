//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol SeriesScalar: MetricScalar {
    static var seriesValues: String { get }
    init(_ value: Double)
    var metricValue: MetricValue { get }
}

extension Int: SeriesScalar {
    static var seriesValues: String { "int" }
    var metricValue: MetricValue { .int(self) }
}

extension Double: SeriesScalar {
    static var seriesValues: String { "double" }
    var metricValue: MetricValue { .double(self) }
}
