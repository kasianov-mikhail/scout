//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct SummaryRow<Destination: View>: View {
    let title: String
    let color: Color
    var titleColor: Color = .primary
    var systemImage: String? = nil
    let series: MiniChartSeries?
    let count: Int?
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        Row {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .frame(width: 24)
            }
            Text(title)
                .foregroundColor(titleColor)
            Spacer()

            RowSummary(series: series, count: count, color: color)
        } destination: {
            destination()
        }
    }
}
