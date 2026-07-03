//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct LatencyPercentiles: Equatable {
    let p50: TimeInterval
    let p90: TimeInterval
    let p99: TimeInterval
}

struct TimerDistributionView: View {
    let percentiles: LatencyPercentiles
    let trend: [PercentileTrendPoint]
    let unit: Calendar.Component

    var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            summary

            Text(verbatim: "P99 TREND")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.gray)

            PercentileTrendChart(trend: trend, unit: unit)
        }
        .padding(.vertical)
    }

    private var summary: some View {
        HStack(spacing: 34) {
            Metric(title: "P50", value: percentiles.p50.duration, color: .blue)
            Metric(title: "P90", value: percentiles.p90.duration, color: .teal)
            Metric(title: "P99", value: percentiles.p99.duration, color: .orange)
            Spacer()
        }
    }
}

extension LatencyPercentiles {
    static var sample: LatencyPercentiles {
        LatencyPercentiles(p50: 0.081, p90: 0.42, p99: 3.8)
    }
}

#Preview("TimerDistributionView") {
    NavigationStack {
        ScrollView {
            TimerDistributionView(percentiles: .sample, trend: .sample, unit: .hour)
                .padding(.horizontal)
        }
        .navigationTitle(en: "http_request")
    }
}
