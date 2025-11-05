//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsContent<T: ChartNumeric>: View {
    let period: Period
    let formatter: KeyPath<T, String>

    @ObservedObject var metrics: MetricsProvider<T>
    @EnvironmentObject var database: DatabaseController

    var body: some View {
        ProviderView(provider: metrics) { data in
            let groups = data.pointGroups()
            let ranked = groups.ranked(on: period)

            if ranked.isEmpty {
                Placeholder(text: "No results").frame(maxHeight: .infinity)
            } else {
                List(ranked) { group in
                    Row {
                        row(group: group)
                    } destination: {
                        @State var extent = ChartExtent(period: period)

                        if let named = groups.named(group.name) {
                            MetricsView(
                                group: named,
                                formatter: formatter,
                                extent: extent
                            )
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .task {
            await metrics.fetchAgain(in: database)
        }
    }

    private func row(group: PointGroup<T>) -> some View {
        HStack {
            Text(group.name)
            Spacer()
            Text(group.points.total[keyPath: formatter])
        }
        .monospaced()
        .font(.system(size: 17))
        .lineLimit(1)
    }
}
