//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct PercentileRow: View {
    let percentiles: Percentiles
    let formatter: KeyPath<Double, String>

    var body: some View {
        HStack(spacing: 34) {
            Readout(title: "P50", value: percentiles.p50[keyPath: formatter], color: .blue)
            Readout(title: "P90", value: percentiles.p90[keyPath: formatter], color: .teal)
            Readout(title: "P99", value: percentiles.p99[keyPath: formatter], color: .orange)
            Spacer()
        }
    }
}
