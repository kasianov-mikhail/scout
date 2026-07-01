//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct VersionDetailView: View {
    @Environment(\.database) var database

    let release: ReleaseHealth
    @StateObject private var crashProvider: VersionCrashProvider

    init(release: ReleaseHealth, crashProvider: VersionCrashProvider? = nil) {
        self.release = release
        self._crashProvider = StateObject(wrappedValue: crashProvider ?? VersionCrashProvider(version: release.id))
    }

    private var crashes: [Crash] {
        crashProvider.crashes ?? []
    }

    private var issues: [CrashGroup] {
        CrashGroup.groups(from: crashes)
    }

    var body: some View {
        List {
            headerSection
            trendSection
            issuesSection
        }
        .listStyle(.plain)
        .toolbarBackground(release.freeSessions.color.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(en: release.id)
        .task {
            await crashProvider.fetchIfNeeded(in: database)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 24) {
                Metric(title: "Crash-free sessions", stability: release.freeSessions)
                if let freeUsers = release.freeUsers {
                    Metric(title: "Crash-free users", stability: freeUsers)
                }
            }

            HStack(spacing: 24) {
                Metric(title: "Crashes", value: "\(release.crashes)")
                Metric(title: "Sessions", value: release.sessions.compact)
                Metric(title: "Adoption", value: release.adoption.formatted)
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
            let count = crashes.filter { crash in
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
            .foregroundStyle(release.freeSessions.color.gradient)
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
        .chartBackground { _ in
            if !dailyCrashes.contains(where: { $0.count > 0 }) {
                ChartPlaceholder().offset(y: -12)
            }
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
}

#Preview {
    NavigationStack {
        VersionDetailView(release: ReleaseHealth.samples[0], crashProvider: .fixture())
    }
    .environmentObject(Tint())
}

#Preview("Empty graph") {
    let release = ReleaseHealth.samples[0]

    return NavigationStack {
        VersionDetailView(
            release: release,
            crashProvider: VersionCrashProvider(version: release.id, crashes: [])
        )
    }
    .environmentObject(Tint())
}
