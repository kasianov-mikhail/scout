//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct MetricDetailView: View {
    let name: String
    let telemetry: Telemetry.Export

    @State private var range: MetricRange

    init(name: String, telemetry: Telemetry.Export, range: MetricRange) {
        self.name = name
        self.telemetry = telemetry
        self._range = State(wrappedValue: range)
    }

    var body: some View {
        content
            .monospacedNavigationTitle(en: name)
    }

    @ViewBuilder
    private var content: some View {
        switch telemetry {
        case .counter:
            MetricSeriesDetailView<Int>(name: name, telemetry: telemetry, range: $range)
        case .floatingCounter, .meter:
            MetricSeriesDetailView<Double>(name: name, telemetry: telemetry, range: $range)
        case .timer:
            MetricDistributionDetailView<LatencyHistogram>(
                name: name,
                telemetry: telemetry,
                categories: LatencyBuckets.categories,
                range: $range
            )
        case .recorder:
            MetricDistributionDetailView<RecorderHistogram>(
                name: name,
                telemetry: telemetry,
                categories: RecorderBuckets.categories,
                range: $range
            )
        }
    }
}
