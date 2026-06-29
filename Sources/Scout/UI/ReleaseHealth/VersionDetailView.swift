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

    private var issues: [CrashGroup] {
        CrashGroup.groups(from: release.crashes)
    }

    var body: some View {
        List {
            headerSection
            trendSection
            issuesSection
        }
        .listStyle(.plain)
        .toolbarBackground(release.crashFreeSessions.color.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(en: release.version.version)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 24) {
                metric(
                    title: "Crash-free sessions", value: release.crashFreeSessions.formatted,
                    color: release.crashFreeSessions.color)
                metric(
                    title: "Crash-free users", value: release.crashFreeUsers.formatted, color: release.crashFreeUsers.color)
            }

            HStack(spacing: 24) {
                metric(title: "Crashes", value: "\(release.crashes.count)")
                metric(title: "Sessions", value: ReleaseHealth.compact(release.sessions))
                metric(title: "Adoption", value: release.adoption.formatted)
            }
        }
        .padding(.vertical, 4)
        .listRowSeparator(.hidden)
    }

    private var dailyCrashes: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<14).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let count = release.crashes.filter { crash in
                guard let date = crash.date else { return false }
                return date >= day && date < next
            }
            .count
            return (day, count)
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
            .foregroundStyle(release.crashFreeSessions.color.gradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: Calendar.Component.day.chartFormat)
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
        if issues.count > 0 {
            Header(title: "Top issues")

            ForEach(issues) { group in
                Row {
                    Text(verbatim: group.name)
                        .font(.system(size: 16))
                        .monospaced()
                        .lineLimit(1)

                    Spacer()

                    CountBadge(count: group.count)
                } destination: {
                    CrashGroupDetailView(group: group)
                }
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
        VersionDetailView(release: ReleaseHealth.samples[0])
    }
    .environmentObject(Tint())
}
