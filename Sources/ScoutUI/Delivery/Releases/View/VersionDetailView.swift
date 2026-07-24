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
    let release: ReleaseHealth
    @StateObject var crashes: VersionIncidentProvider<Crash>
    @StateObject var hangs: VersionIncidentProvider<Hang>

    @State private var showAllCrashes = false
    @State private var showAllHangs = false

    init(
        release: ReleaseHealth, crashes: VersionIncidentProvider<Crash>? = nil,
        hangs: VersionIncidentProvider<Hang>? = nil
    ) {
        self.release = release
        self._crashes = StateObject(wrappedValue: crashes ?? VersionIncidentProvider(version: release.id))
        self._hangs = StateObject(wrappedValue: hangs ?? VersionIncidentProvider(version: release.id))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: -8) {
                HStack(spacing: 24) {
                    Readout(title: "Crash-free sessions", stability: release.freeSessions)
                    if let freeUsers = release.freeUsers {
                        Readout(title: "Crash-free users", stability: freeUsers)
                    }
                }

                HStack(spacing: 24) {
                    Readout(title: "Crashes", value: "\(release.crashes)")
                    Readout(title: "Hangs", value: "\(release.hangs)")
                    Readout(title: "Sessions", value: release.sessions.compact)
                    Readout(title: "Adoption", value: release.adoption.formatted)
                }
            }
            .padding(.top)
            .padding(.bottom, 4)
            .listRowSeparator(.hidden, edges: .top)

            IncidentTrendSection(title: "Crashes", records: crashRecords, color: .red) {
                if crashRecords.count > 0 {
                    AllButton { showAllCrashes = true }
                }
            }

            IncidentTrendSection(title: "Hangs", records: hangRecords, color: .orange) {
                if hangRecords.count > 0 {
                    AllButton { showAllHangs = true }
                }
            }
        }
        .navigationDestination(isPresented: $showAllCrashes) {
            VersionIncidentsView(
                title: "Crashes",
                issuesTitle: "Top crash issues",
                records: crashRecords,
                color: .red
            ) { group in
                CrashGroupDetailView(group: group)
            }
        }
        .navigationDestination(isPresented: $showAllHangs) {
            VersionIncidentsView(
                title: "Hangs",
                issuesTitle: "Top hang issues",
                records: hangRecords,
                color: .orange
            ) { group in
                HangGroupDetailView(group: group)
            }
        }
        .toolbarBackground(release.freeSessions.color.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: release.id)
        .message($crashes.message)
        .message($hangs.message)
        .periodRefresh(providers: [crashes, hangs])
    }

    private var crashRecords: [Crash] {
        crashes.records ?? []
    }

    private var hangRecords: [Hang] {
        hangs.records ?? []
    }
}

private struct VersionIncidentsView<Element: Incident, Destination: View>: View {
    let title: String
    let issuesTitle: String
    let records: [Element]
    let color: Color

    @ViewBuilder let destination: (IncidentGroup<Element>) -> Destination

    var body: some View {
        InsetList {
            IncidentTrendChart(records: records, color: color)
                .padding(.top)

            IncidentIssuesSection(
                title: issuesTitle,
                groups: IncidentGroup.groups(from: records),
                color: color,
                destination: destination
            )
        }
        .navigationTitle(en: title)
        .largeNavigationTitle()
    }
}

private struct IncidentTrendSection<Element: Incident, Trailing: View>: View {
    let title: String
    let records: [Element]
    let color: Color

    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        Header(title: title, trailing: trailing)

        IncidentTrendChart(records: records, color: color)
    }
}

private struct IncidentTrendChart<Element: Incident>: View {
    let records: [Element]
    let color: Color

    private var days: [DailyCount] {
        DailyCount.series(from: records)
    }

    var body: some View {
        let isEmpty = !days.contains(where: { $0.count > 0 })

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
        .listRowSeparator(.hidden)
    }
}

private struct IncidentIssuesSection<Element: Incident, Destination: View>: View {
    let title: String
    let groups: [IncidentGroup<Element>]
    let color: Color
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

                    CountBadge(count: group.count, color: color)
                } destination: {
                    destination(group)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VersionDetailView(
            release: [ReleaseHealth].samples[0],
            crashes: .init(.samples, version: "3.2.0"),
            hangs: .init(.samples, version: "3.2.0")
        )
    }
    .environmentObject(Tint())
}

#Preview("Empty graph") {
    let release = [ReleaseHealth].samples[0]

    return NavigationStack {
        VersionDetailView(
            release: release,
            crashes: .init([], version: release.id),
            hangs: .init([], version: release.id)
        )
    }
    .environmentObject(Tint())
}
