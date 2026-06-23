//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol MetricSeriesScalar {
    static var seriesValues: String { get }
    init(_ value: Int)
    init(_ value: Double)
}

extension MetricSeriesScalar {
    static func chartValue(_ value: MetricValue) -> Self {
        switch value {
        case .int(let value): Self(value)
        case .double(let value): Self(value)
        }
    }
}

extension Int: MetricSeriesScalar {
    static var seriesValues: String { "int" }
}

extension Double: MetricSeriesScalar {
    static var seriesValues: String { "double" }
}
