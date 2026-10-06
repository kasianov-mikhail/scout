//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoSample {
    enum Source {
        case event, lifecycle, metric
    }

    let name: String
    let category: String?
    let version: String?
    let source: Source
    let date: Date
    let values: MetricSeriesQuery.Values
    let value: Double

    init(name: String, category: String? = nil, version: String? = nil, source: Source, date: Date, values: MetricSeriesQuery.Values = .int, value: Double = 1) {
        self.name = name
        self.category = category
        self.version = version
        self.source = source
        self.date = date
        self.values = values
        self.value = value
    }
}
