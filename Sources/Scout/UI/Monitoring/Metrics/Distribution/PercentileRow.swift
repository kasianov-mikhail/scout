//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct PercentileRow: View {
    let percentiles: LatencyPercentiles

    var body: some View {
        HStack(spacing: 34) {
            Metric(title: "P50", value: percentiles.p50.duration, color: .blue)
            Metric(title: "P90", value: percentiles.p90.duration, color: .teal)
            Metric(title: "P99", value: percentiles.p99.duration, color: .orange)
            Spacer()
        }
    }
}
