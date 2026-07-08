//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HangGroupDetailView: View {
    let group: IncidentGroup<Hang>

    var body: some View {
        List {
            headerSection
            occurrencesSection
        }
        .listStyle(.plain)
        .navigationTint(group.severity.color)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let text = HangGroupExport(group: group).text
                ShareLink(item: text)
                    .tint(Color.primary)
                CopyButton(text: text)
                    .tint(Color.primary)
                Spacer()
            }
        }
        .navigationTitle(group.name)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Metric(title: "Duration", value: group.durationText, color: group.severity.color)
                Metric(title: "Occurrences", value: "\(group.count)")
                Metric(title: "Devices", value: "\(group.affectedDevices)")
                Metric(title: "Sessions", value: "\(group.affectedSessions)")
            }

            if let first = group.firstDate, let last = group.lastDate {
                Text(verbatim: "First seen \(first.relativeString) · Last seen \(last.relativeString)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var occurrencesSection: some View {
        Header(title: "Occurrences")

        ForEach(group.records) { hang in
            Row {
                if let date = hang.date {
                    UTCTimestampText(date: date, size: 14)
                }

                Spacer()

                Text(verbatim: hang.durationText)
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(hang.severity.color)
            } destination: {
                HangDetailView(hang: hang)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HangGroupDetailView(
            group: IncidentGroup(records: [
                .sample("Image Layout Pass", duration: 9.8, at: Date()),
                .sample("Image Layout Pass", duration: 4.6, at: Date().addingTimeInterval(-3600)),
            ])
        )
    }
    .environmentObject(Tint())
}
