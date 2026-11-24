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

    init(group: IncidentGroup<Crash>, breakdown: IncidentBreakdownProvider? = nil, range: IncidentRange = .year) {
        _occurrences = StateObject(wrappedValue: IncidentOccurrencesProvider(group: group, range: range))
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
            if let error = occurrences.error {
                ErrorView(description: error.localizedDescription) {
                    await occurrences.fetchIfNeeded(in: database)
                }
            } else if occurrences.records != nil, occurrences.currentRecords.isEmpty {
                Placeholder(text: "No occurrences")
            } else {
                ScrollView {
                    if occurrences.records != nil {
                        content()
                            .transition(.opacity)
                    } else {
                        IncidentGroupPlaceholder(kind: .crash)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: occurrences.records == nil)
        .loadingInk(isLoading: occurrences.records == nil)
        .message($occurrences.message)
        .toolbarBackground(IncidentKind.crash.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: occurrences.name, divider: IncidentKind.crash.border)
        .task {
            await occurrences.fetchIfNeeded(in: database)
        }
        .task(id: occurrences.currentRecords.map(\.id)) {
            if occurrences.records != nil {
                await breakdown.fetch(deviceIDs: occurrences.group.deviceIDs, sessionIDs: occurrences.group.sessionIDs, in: database)
            }
        }
    }

    private func content() -> some View {
        IncidentSummaryView(
            summary: summary(),
            records: occurrences.currentRecords,
            row: occurrenceRow
        )
        .exportToolbar(text: CrashGroupExport(group: occurrences.group).text, tint: .primary)
    }

    private func summary() -> IncidentSummary {
        let group = occurrences.group
        return IncidentSummary(
            kind: .crash,
            label: "Crash",
            message: group.representative.reason,
            group: group,
            breakdown: breakdown.value,
            cards: [
                .occurrences(records: occurrences.currentRecords, previous: occurrences.previousRecords, range: occurrences.range, value: group.occurrencesText, now: occurrences.now),
                .devices(records: occurrences.currentRecords, previous: occurrences.previousRecords, range: occurrences.range, value: group.devicesText, now: occurrences.now),
            ],
            stack: group.representative.stackTrace
        )
    }

    private func occurrenceRow(_ crash: Crash) -> some View {
        NavigationLink {
            CrashDetailView(crash: crash, group: occurrences.group)
        } label: {
            HStack(spacing: .space8) {
                if let date = crash.date {
                    Text(verbatim: date.relativeString)
                        .font(.scoutRow)
                }

                Spacer()

                if let label = breakdown.value?.occurrenceLabel(record: crash) {
                    Text(verbatim: label)
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                }
            }
            .lineLimit(1)
            .frame(height: .rowRegular)
            .contentShape(.rect)
        }
        .buttonStyle(.solid)
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
