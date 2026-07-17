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
        .task { await retention.fetchIfNeeded(in: database) }

        switch retention.result {
        case .success(let cohorts) where cohorts.count > 0:
            RetentionContent(cohorts: cohorts, path: $path)

        case .success:
            Text(verbatim: "No results")
                .placeholderTextStyle()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowSeparator(.hidden)

        default:
            RetentionPlaceholder()
        }
    }
}

private struct RetentionContent: View {
    let cohorts: [RetentionCohort]

    @Binding var path: [HomeDestination]

    var body: some View {
        let stats = RetentionCohort.stats(for: cohorts)
        let series = MiniChartSeries(values: stats.map { Int(($0.average * 100).rounded()) })

        HomeRetentionRow(series: series) { path.append(.retention) }

        ForEach(RetentionCohort.summaryOffsets, id: \.self) { day in
            RetentionMilestoneRow(day: day, rate: stats.first { $0.day == day }?.average) {
                path.append(.retention)
            }
        }
    }
}

private struct RetentionPlaceholder: View {
    var body: some View {
        HomeRetentionRow(series: .placeholder) {}
            .redacted(reason: .placeholder)

        ForEach(RetentionCohort.summaryOffsets, id: \.self) { day in
            RetentionMilestoneRow(day: day, rate: nil) {}
                .redacted(reason: .placeholder)
        }
    }
}

private struct RetentionMilestoneRow: View {
    let day: Int
    let rate: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
