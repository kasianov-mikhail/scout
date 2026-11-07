//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HangGroupDetailView: View {
    @StateObject private var occurrences: IncidentOccurrencesProvider<Hang>
    @StateObject private var breakdown: IncidentBreakdownProvider
    @Environment(\.database) var database

    init(group: IncidentGroup<Hang>, breakdown: IncidentBreakdownProvider? = nil) {
        _occurrences = StateObject(wrappedValue: IncidentOccurrencesProvider(group: group))
        _breakdown = StateObject(
            wrappedValue: breakdown
                ?? IncidentBreakdownProvider(
                    deviceIDs: group.deviceIDs,
                    sessionIDs: group.sessionIDs
                )
        )
    }

    init(occurrences: IncidentOccurrencesProvider<Hang>) {
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
                IncidentGroupPlaceholder(kind: .hang)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: occurrences.records == nil)
        .message($occurrences.message)
        .toolbarBackground(IncidentKind.hang.background, for: .navigationBar)
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

    private func content(records: [Hang]) -> some View {
        IncidentSummaryView(
            summary: summary(records: records),
            records: records,
            row: occurrenceRow
        ) {
            IncidentOccurrencesView(occurrences: occurrences, row: occurrenceRow)
        }
        .exportToolbar(text: HangGroupExport(group: occurrences.group).text, tint: .primary)
    }

    private func summary(records: [Hang]) -> IncidentSummary {
        let group = occurrences.group
        return IncidentSummary(
            kind: .hang,
            label: group.severity.label,
            message: group.peak.reason,
            group: group,
            breakdown: breakdown.value,
            cards: [
                .occurrences(records: records, value: group.occurrencesText),
                .longest(records: records),
            ],
            stack: group.peak.stackTrace
        )
    }

    private func occurrenceRow(_ hang: Hang) -> some View {
        Row {
            if let date = hang.date {
                Text(verbatim: date.relativeString)
                    .font(.system(size: 15))
            }

            Spacer()

            if let label = breakdown.value?.occurrenceLabel(record: hang) {
                Text(verbatim: label)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }
        } destination: {
            HangDetailView(hang: hang)
        }
    }
}

#Preview {
    NavigationStack {
        HangGroupDetailView(
            group: IncidentGroup(records: [
                .sample("Image Layout Pass", duration: 9.8, at: Date()),
                .sample("Image Layout Pass", duration: 4.6, at: Date().addingTimeInterval(-3600)),
            ]),
            breakdown: .init(.success(.sample), deviceIDs: [], sessionIDs: [])
        )
    }
    .environmentObject(Tint())
}
