//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

typealias LatencyPercentiles = Percentiles

struct Percentiles: Equatable {
    let p50: Double
    let p90: Double
    let p99: Double
}

struct MetricDistributionView: View {
    let percentiles: Percentiles
    let trend: [PercentileTrendPoint]
    let unit: Calendar.Component
    let formatter: KeyPath<Double, String>

    var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            PercentileRow(percentiles: percentiles, formatter: formatter)

            Text(verbatim: "P99 TREND")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.gray)

            PercentileTrendChart(trend: trend, unit: unit, formatter: formatter)
        }
        .padding(.vertical)
    }
}

extension Percentiles {
    static var sample: Percentiles {
        Percentiles(p50: 0.081, p90: 0.42, p99: 3.8)
    }
}

#Preview("MetricDistributionView") {
    NavigationStack {
        ScrollView {
            MetricDistributionView(percentiles: .sample, trend: .sample, unit: .hour, formatter: \TimeInterval.duration)
                .padding(.horizontal)
        }
        .monospacedNavigationTitle(en: "http_request")
    }
}
