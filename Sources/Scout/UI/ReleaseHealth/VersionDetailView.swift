//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

private struct CountBadge: View {
    let count: Int
    var color: Color = .red

    var body: some View {
        Text(verbatim: "\(count)")
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.13), in: Capsule())
    }
}

struct VersionDetailView: View {
    let release: ReleaseHealth

    private let topIssues: [(name: String, count: Int)] = [
        ("NSRangeException", 6),
        ("Fatal error", 4),
        ("SIGSEGV", 2),
        ("NSInvalidArgumentException", 1),
    ]

    var body: some View {
        List {
            headerSection
            trendSection
            issuesSection
        }
        .listStyle(.plain)
        .toolbarBackground(ReleaseHealth.healthColor(release.crashFreeSessions).opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(en: release.version)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 24) {
                metric(title: "Crash-free sessions", value: ReleaseHealth.percent(release.crashFreeSessions), color: ReleaseHealth.healthColor(release.crashFreeSessions))
                metric(title: "Crash-free users", value: ReleaseHealth.percent(release.crashFreeUsers), color: ReleaseHealth.healthColor(release.crashFreeUsers))
            }

            HStack(spacing: 24) {
                metric(title: "Crashes", value: "\(release.crashes)")
                metric(title: "Sessions", value: ReleaseHealth.compact(release.sessions))
                metric(title: "Adoption", value: "\(Int((release.adoption * 100).rounded()))%")
            }
        }
        .padding(.vertical, 4)
        .listRowSeparator(.hidden)
    }

    private var dailyCrashes: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let base = [5, 7, 6, 9, 8, 11, 7, 6, 8, 5, 7, 10, 6, 4]
        let factor = max(1, Int((Double(release.crashes) / 40).rounded()))

        return base.indices.map { index in
            let date = calendar.date(byAdding: .day, value: -(base.count - 1 - index), to: today) ?? today
            return (date, base[index] * factor)
        }
    }

    @ViewBuilder
    private var trendSection: some View {
        Header(title: "Crashes over time")

        Chart(dailyCrashes, id: \.date) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value("Crashes", day.count),
                width: .ratio(0.6)
            )
            .foregroundStyle(ReleaseHealth.healthColor(release.crashFreeSessions).gradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 170)
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private var issuesSection: some View {
        Header(title: "Top issues")

        ForEach(topIssues, id: \.name) { issue in
            Row {
                Text(verbatim: issue.name)
                    .font(.system(size: 16))
                    .monospaced()
                    .lineLimit(1)

                Spacer()

                CountBadge(count: issue.count)
            } destination: {
                Text(verbatim: issue.name)
            }
        }
    }

    private func metric(title: String, value: String, color: Color = .primary) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: value)
                .font(.system(size: 22, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(color)
            Text(verbatim: title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.gray)
        }
    }
}

#Preview {
    NavigationStack {
        VersionDetailView(release: ReleaseHealth.sample[0])
    }
}
