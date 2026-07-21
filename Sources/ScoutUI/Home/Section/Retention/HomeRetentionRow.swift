//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeRetentionRow: View {
    let series: MiniChartSeries
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Sparkline(series: series, color: .green, gridlinesAtPoints: true)
                .frame(height: 68)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    InsetList {
        HomeRetentionRow(series: MiniChartSeries(values: [100, 42, 28, 19, 13, 8])) {}
    }
}
