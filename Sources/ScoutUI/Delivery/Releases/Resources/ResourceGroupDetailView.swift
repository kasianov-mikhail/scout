//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ResourceGroupDetailView: View {
    let group: IncidentGroup<ResourceException>

    @StateObject private var breakdown: IncidentBreakdownProvider
    @Environment(\.database) var database

    init(group: IncidentGroup<ResourceException>, breakdown: IncidentBreakdownProvider? = nil) {
        self.group = group
        self._breakdown = StateObject(
            wrappedValue: breakdown
                ?? IncidentBreakdownProvider(deviceIDs: group.deviceIDs, sessionIDs: group.sessionIDs))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Readout(title: "Occurrences", value: group.occurrencesText, color: IncidentKind.resource.color)
                    Readout(title: "Devices", value: group.devicesText)
                    Readout(title: "Sessions", value: group.sessionsText)
                }

                if let first = group.firstDate, let last = group.lastDate {
                    Text(verbatim: "\(group.firstSeenLabel) \(first.relativeString) · Last seen \(last.relativeString)")
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
        .navigationTint(IncidentKind.resource.color)
        .monospacedNavigationTitle(en: group.name)
        .task {
            await breakdown.fetchIfNeeded(in: database)
        }
    }

    private func occurrenceRow(_ resource: ResourceException) -> some View {
        Row {
            if let date = resource.date {
                UTCTimestampText(date: date, size: 14)
            }

            Spacer()

            if let reason = resource.reason {
                Text(verbatim: reason)
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(IncidentKind.resource.color)
            }
        } destination: {
            ResourceDetailView(resource: resource)
        }
    }
}

#Preview {
    NavigationStack {
        ResourceGroupDetailView(group: IncidentGroup(records: [ResourceException].samples.filter { $0.resourceKind == .cpu }))
    }
    .environmentObject(Tint())
}
