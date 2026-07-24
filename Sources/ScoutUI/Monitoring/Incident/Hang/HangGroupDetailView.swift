//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HangGroupDetailView: View {
    let group: IncidentGroup<Hang>

    @StateObject private var breakdown: IncidentBreakdownProvider
    @Environment(\.database) var database

    init(group: IncidentGroup<Hang>, breakdown: IncidentBreakdownProvider? = nil) {
        self.group = group
        self._breakdown = StateObject(
            wrappedValue: breakdown
                ?? IncidentBreakdownProvider(deviceIDs: group.deviceIDs, sessionIDs: group.sessionIDs))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Readout(title: "Duration", value: group.durationText, color: group.severity.color)
                    Readout(title: "Occurrences", value: "\(group.count)")
                    Readout(title: "Devices", value: "\(group.affectedDevices)")
                    Readout(title: "Sessions", value: "\(group.affectedSessions)")
                }

                if let first = group.firstDate, let last = group.lastDate {
                    Text(verbatim: "First seen \(first.relativeString) · Last seen \(last.relativeString)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.bottom)

            if let value = try? breakdown.result?.get() {
                IncidentBreakdownSection(breakdown: value, records: group.records, row: occurrenceRow)
            }

            Header(title: "Occurrences")

            ForEach(group.records, content: occurrenceRow)
        }
        .navigationTint(group.severity.color)
        .exportToolbar(text: HangGroupExport(group: group).text, tint: .primary)
        .monospacedNavigationTitle(en: group.name)
        .task {
            await breakdown.fetchIfNeeded(in: database)
        }
    }

    private func occurrenceRow(_ hang: Hang) -> some View {
        Row {
            if let date = hang.date {
                UTCTimestampText(date: date, size: 14)
            }

            Spacer()

            Text(verbatim: hang.duration.duration)
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(hang.severity.color)
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
            breakdown: .init(deviceIDs: [], sessionIDs: []).holding(.sample)
        )
    }
    .environmentObject(Tint())
}
