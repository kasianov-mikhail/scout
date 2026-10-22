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
        InsetList {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 24) {
                    Readout(title: "Occurrences", value: occurrences.group.occurrencesText)
                    Readout(title: "Devices", value: occurrences.group.devicesText)
                    Readout(title: "Sessions", value: occurrences.group.sessionsText)
                }

                if let reason = occurrences.group.representative.reason {
                    Text(verbatim: "REASON:   ").fontWeight(.bold)
                        + Text(reason).fontWeight(.bold).foregroundColor(.red)
                }

                if let first = occurrences.group.firstDate, let last = occurrences.group.lastDate {
                    Text(verbatim: "\(occurrences.group.firstSeenLabel) \(first.relativeString) · Last seen \(last.relativeString)")
                        .font(.system(size: 14))
                        .padding(.bottom)
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.vertical, 4)

            IncidentBreakdownSection(
                breakdown: breakdown,
                records: occurrences.group.records,
                row: occurrenceRow
            )

            Header(title: "Occurrences")

            ForEach(occurrences.group.records, content: occurrenceRow)

            if let cursor = occurrences.cursor {
                PaginationFooter {
                    await occurrences.fetchMore(cursor: cursor, in: database)
                }
            }
        }
        .navigationTint(.red)
        .exportToolbar(text: CrashGroupExport(group: occurrences.group).text, tint: .primary)
        .monospacedNavigationTitle(en: occurrences.group.name)
        .task {
            await occurrences.fetchIfNeeded(in: database)
        }
        .task(id: occurrences.records?.map(\.id)) {
            if occurrences.records != nil {
                await breakdown.fetch(deviceIDs: occurrences.group.deviceIDs, sessionIDs: occurrences.group.sessionIDs, in: database)
            }
        }
    }

    private func occurrenceRow(_ crash: Crash) -> some View {
        Row {
            if let date = crash.date {
                UTCTimestampText(date: date, size: 14)
            }

            Spacer()

            if let sessionID = crash.sessionID {
                Text(ExportFormat.shortID(sessionID))
                    .font(.footnote)
                    .monospaced()
                    .foregroundStyle(Color.gray)
            }
        } destination: {
            CrashDetailView(crash: crash)
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
