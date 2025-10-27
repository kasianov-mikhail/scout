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
        if let data = metrics.data {
            list(groups: data.pointGroups())
        } else {
            ProgressView().frame(maxHeight: .infinity).task {
                await metrics.fetchIfNeeded(in: database)
            }
        }
    }

    @ViewBuilder
    private func list(groups: [PointGroup<T>]) -> some View {
        let ranked = groups.ranked(on: period)

        if ranked.isEmpty {
            Placeholder(text: "No results").frame(maxHeight: .infinity)
        } else {
            List(ranked) { group in
                Row {
                    row(group: group)
                } destination: {
                    if let named = groups.named(group.name) {
                        MetricsView(group: named, formatter: formatter, period: period)
                    }
                }
            }
            .listStyle(.plain)
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
