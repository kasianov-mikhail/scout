//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatRow<Destination: View>: View {
    let color: Color
    let period: Period
    var systemImage: String? = nil

    @ObservedObject var stat: StatProvider
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        let points = points

        Row {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                    .frame(width: 24)
            }
            Text(period.title)
                .foregroundStyle(systemImage == nil ? color : .primary)
            Spacer()

            RowSummary(
                series: points.map { MiniChartSeries(points: $0, range: period.initialRange, aggregation: .total) }
                    ?? .empty,
                count: points?.bucket(on: period).total,
                color: color
            )
        } destination: {
            destination()
        }
    }

    private var points: [ChartPoint<Int>]? {
        switch stat.result {
        case .success(let points):
            points
        case .failure, nil:
            nil
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            StatRow(
                color: .blue,
                period: .today,
                stat: StatProvider(subject: .event("event_name"))
            ) {
                Text(verbatim: "Detail")
            }
        }
    }
}
