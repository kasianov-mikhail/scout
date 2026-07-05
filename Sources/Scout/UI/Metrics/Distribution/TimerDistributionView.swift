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
            PercentileRow(percentiles: percentiles)

            Text(verbatim: "P99 TREND")
                .font(.fixedCaption.weight(.semibold))
                .foregroundStyle(Color.gray)

            PercentileTrendChart(trend: trend, unit: unit)
        }
        .padding(.vertical)
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
