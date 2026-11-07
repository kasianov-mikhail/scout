//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct CrashGroupDetailView: View {
    @StateObject private var occurrences: IncidentOccurrencesProvider<Crash>
    @StateObject private var breakdown: IncidentBreakdownProvider
    @Environment(\.database) var database

    init(group: IncidentGroup<Crash>, breakdown: IncidentBreakdownProvider? = nil) {
        _occurrences = StateObject(wrappedValue: IncidentOccurrencesProvider(group: group))
        _breakdown = StateObject(
            wrappedValue: breakdown
                ?? IncidentBreakdownProvider(
                    deviceIDs: group.deviceIDs,
                    sessionIDs: group.sessionIDs
                )
        )
    }

    init(occurrences: IncidentOccurrencesProvider<Crash>) {
        _occurrences = StateObject(wrappedValue: occurrences)
        _breakdown = StateObject(
            wrappedValue: IncidentBreakdownProvider(
                deviceIDs: occurrences.group.deviceIDs,
                sessionIDs: occurrences.group.sessionIDs
            )
        )
    }

    var body: some View {
        Group {
            if let records = occurrences.records {
                if records.isEmpty {
                    Placeholder(text: "No occurrences")
                } else {
                    content(records: records)
                        .transition(.opacity)
                }
            } else if let error = occurrences.error {
                ErrorView(description: error.localizedDescription) {
                    await occurrences.fetchIfNeeded(in: database)
                }
            } else {
                IncidentGroupPlaceholder(kind: .crash)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: occurrences.records == nil)
        .message($occurrences.message)
        .toolbarBackground(IncidentKind.crash.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: occurrences.name)
        .task {
            await occurrences.fetchIfNeeded(in: database)
        }
        .task(id: occurrences.records?.map(\.id)) {
            if occurrences.records != nil {
                await breakdown.fetch(deviceIDs: occurrences.group.deviceIDs, sessionIDs: occurrences.group.sessionIDs, in: database)
            }
        }
    }

    private func content(records: [Crash]) -> some View {
        IncidentSummaryView(
            summary: summary(records: records),
            records: records,
            row: occurrenceRow
        ) {
            IncidentOccurrencesView(occurrences: occurrences, row: occurrenceRow)
        }
        .exportToolbar(text: CrashGroupExport(group: occurrences.group).text, tint: .primary)
    }

    private func summary(records: [Crash]) -> IncidentSummary {
        let group = occurrences.group
        return IncidentSummary(
            kind: .crash,
            label: "Crash",
            message: group.representative.reason,
            group: group,
            breakdown: breakdown.value,
            cards: [
                .occurrences(records: records, value: group.occurrencesText),
                .devices(records: records, value: group.devicesText),
            ],
            stack: group.representative.stackTrace
        )
    }

    private func occurrenceRow(_ crash: Crash) -> some View {
        Row {
            if let date = crash.date {
                Text(verbatim: date.relativeString)
                    .font(.system(size: 15))
            }

            Spacer()

            if let label = breakdown.value?.occurrenceLabel(record: crash) {
                Text(verbatim: label)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }
        } destination: {
            CrashDetailView(crash: crash, group: occurrences.group)
        }
    }
}

#Preview {
    NavigationStack {
        CrashGroupDetailView(
            group: IncidentGroup(records: [
                .sample("NSRangeException", at: Date()),
                .sample("NSRangeException", at: Date().addingTimeInterval(-3600)),
            ]),
            breakdown: .init(.success(.sample), deviceIDs: [], sessionIDs: [])
        )
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    let crash = Crash.sample("NSRangeException", at: Date())
    let tally = IncidentTally(fingerprint: crash.fingerprint, name: crash.name, count: 10, firstHour: Date().addingTimeInterval(-86_400))

    NavigationStack {
        CrashGroupDetailView(
            group: IncidentGroup(
                id: crash.fingerprint,
                records: [crash],
                symbol: nil,
                tallies: [crash.fingerprint: tally],
                hasMore: false
            )
        )
    }
    .environmentObject(Tint())
}
