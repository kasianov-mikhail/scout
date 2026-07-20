//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeRetentionSection: View {
    @Environment(\.database) var database

    @ObservedObject var retention: RetentionProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Retention") {
            if let cohorts = try? retention.result?.get(), cohorts.count > 0 {
                AllButton { path.append(.retention) }
            }
        }
        .task {
            await retention.fetchIfNeeded(in: database)
        }

        switch retention.result {
        case .success(let cohorts) where cohorts.count > 0:
            let stats = RetentionCohort.stats(for: cohorts)
            let series = MiniChartSeries(values: stats.map { Int(($0.average * 100).rounded()) })

            HomeRetentionRow(series: series) { path.append(.retention) }

            ForEach(RetentionCohort.summaryOffsets, id: \.self) { day in
                let rate = stats.first { $0.day == day }?.average

                Button {
                    path.append(.retention)
                } label: {
                    HStack {
                        Text(verbatim: "Day \(day)")
                            .font(.subheadline)
                        Spacer()
                        Text(verbatim: rate?.formatted(.retentionRate) ?? "—")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }
                .buttonStyle(.plain)
            }

        case .success:
            Text(verbatim: "No results")
                .placeholderTextStyle()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowSeparator(.hidden, edges: .top)

        default:
            HomeRetentionRow(series: .placeholder) {}
                .redacted(reason: .placeholder)

            ForEach(RetentionCohort.summaryOffsets, id: \.self) { day in
                Button {
                } label: {
                    HStack {
                        Text(verbatim: "Day \(day)")
                            .font(.subheadline)
                        Spacer()
                        Text(verbatim: "—")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }
                .buttonStyle(.plain)
                .redacted(reason: .placeholder)
            }
        }
    }
}

#Preview {
    let retention = RetentionProvider()
    retention.result = .success(.samples)

    return NavigationStack {
        List {
            HomeRetentionSection(retention: retention, path: .constant([]))
            HomeRetentionSection(retention: RetentionProvider(), path: .constant([]))
        }
        .listStyle(.plain)
    }
}
