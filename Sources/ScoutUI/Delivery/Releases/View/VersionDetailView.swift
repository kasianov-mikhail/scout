//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct VersionDetailView: View {
    @Environment(\.database) var database

    let release: ReleaseHealth
    @StateObject var crashes: VersionIncidentProvider<Crash>
    @StateObject var hangs: VersionIncidentProvider<Hang>

    init(
        release: ReleaseHealth, crashes: VersionIncidentProvider<Crash>? = nil,
        hangs: VersionIncidentProvider<Hang>? = nil
    ) {
        self.release = release
        self._crashes = StateObject(wrappedValue: crashes ?? VersionIncidentProvider(version: release.id))
        self._hangs = StateObject(wrappedValue: hangs ?? VersionIncidentProvider(version: release.id))
    }

    var body: some View {
        List {
            headerSection

            IncidentTrendSection(
                title: "Crashes over time", records: crashes.records ?? [], color: .red)
            IncidentIssuesSection(title: "Top crash issues", groups: IncidentGroup.groups(from: crashes.records ?? []))
            { group in
                CrashGroupDetailView(group: group)
            }

            IncidentTrendSection(
                title: "Hangs over time", records: hangs.records ?? [], color: .orange)
            IncidentIssuesSection(title: "Top hang issues", groups: IncidentGroup.groups(from: hangs.records ?? [])) {
                group in
                HangGroupDetailView(group: group)
            }
        }
        .listStyle(.plain)
        .toolbarBackground(release.freeSessions.color.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: release.id)
        .message($crashes.message)
        .message($hangs.message)
        .autoRefresh(rotating: [
            { await crashes.fetchLatest(in: database) },
            { await hangs.fetchLatest(in: database) },
        ])
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
                Metric(title: "Hangs", value: "\(release.hangs)")
                Metric(title: "Sessions", value: release.sessions.compact)
                Metric(title: "Adoption", value: release.adoption.formatted)
            }
        }
        .padding(.vertical, 4)
        .listRowSeparator(.hidden)
    }
}

private struct IncidentTrendSection<Element: Incident>: View {
    let title: String
    let records: [Element]
    let color: Color

    private var days: [DailyCount] {
        DailyCount.series(from: records)
    }

    var body: some View {
        let isEmpty = !days.contains(where: { $0.count > 0 })

        Header(title: title)

        Chart(days, id: \.date) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value("Count", day.count),
                width: .ratio(0.6)
            )
            .foregroundStyle(color.gradient)
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
        .placeholderAxis(active: isEmpty)
        .chartBackground { _ in
            if isEmpty {
                ChartPlaceholder().offset(y: -12)
            }
        }
        .frame(height: 170)
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }
}

private struct IncidentIssuesSection<Element: Incident, Destination: View>: View {
    let title: String
    let groups: [IncidentGroup<Element>]
    @ViewBuilder let destination: (IncidentGroup<Element>) -> Destination

    @ViewBuilder
    var body: some View {
        if groups.count > 0 {
            Header(title: title)

            ForEach(groups) { group in
                Row {
                    Text(verbatim: group.name)
                        .font(.callout)
                        .monospaced()
                        .lineLimit(1)

                    Spacer()

                    CountBadge(count: group.count)
                } destination: {
                    destination(group)
                }
            }
        }
    }
}

#Preview {
    let crashes = VersionIncidentProvider<Crash>(version: "3.2.0")
    crashes.records = .samples

    let hangs = VersionIncidentProvider<Hang>(version: "3.2.0")
    hangs.records = .samples

    return NavigationStack {
        VersionDetailView(release: [ReleaseHealth].samples[0], crashes: crashes, hangs: hangs)
    }
    .environmentObject(Tint())
}

#Preview("Empty graph") {
    let release = [ReleaseHealth].samples[0]

    return NavigationStack {
        VersionDetailView(
            release: release,
            crashes: VersionIncidentProvider(version: release.id, records: []),
            hangs: VersionIncidentProvider(version: release.id, records: [])
        )
    }
    .environmentObject(Tint())
}
