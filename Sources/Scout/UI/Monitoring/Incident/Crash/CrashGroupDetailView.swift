//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashGroupDetailView: View {
    let group: IncidentGroup<Crash>

    @StateObject private var breakdown: IncidentBreakdownProvider
    @Environment(\.database) var database

    init(group: IncidentGroup<Crash>, breakdown: IncidentBreakdownProvider? = nil) {
        self.group = group
        self._breakdown = StateObject(
            wrappedValue: breakdown
                ?? IncidentBreakdownProvider(deviceIDs: group.deviceIDs, sessionIDs: group.sessionIDs))
    }

    var body: some View {
        List {
            headerSection
            breakdownSection
            occurrencesSection
        }
        .listStyle(.plain)
        .navigationTint(.red)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let text = CrashGroupExport(group: group).text
                ShareLink(item: text)
                    .tint(Color.primary)
                CopyButton(text: text)
                    .tint(Color.primary)
                Spacer()
            }
        }
        .monospacedNavigationTitle(en: group.name)
        .task {
            await breakdown.fetchIfNeeded(in: database)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 24) {
                Metric(title: "Occurrences", value: "\(group.count)")
                Metric(title: "Devices", value: "\(group.affectedDevices)")
                Metric(title: "Sessions", value: "\(group.affectedSessions)")
            }

            if let reason = group.representative.reason {
                Text(verbatim: "REASON:   ").fontWeight(.bold)
                    + Text(reason).fontWeight(.bold).foregroundColor(.red)
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
    private var breakdownSection: some View {
        if let value = try? breakdown.result?.get() {
            if value.devices.count > 0 {
                Header(title: "Top Devices")
                SegmentBar(segments: value.devices)
                    .listRowSeparator(.hidden, edges: .bottom)
            }

            if value.osVersions.count > 0 {
                Header(title: "OS Versions")
                SegmentBar(segments: value.osVersions)
                    .listRowSeparator(.hidden, edges: .bottom)
            }
        }
    }

    @ViewBuilder
    private var occurrencesSection: some View {
        Header(title: "Occurrences")

        ForEach(group.records) { crash in
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
}

#Preview {
    let breakdown = IncidentBreakdownProvider(deviceIDs: [], sessionIDs: [])
    breakdown.result = .success(.sample)

    return NavigationStack {
        CrashGroupDetailView(
            group: IncidentGroup(records: [
                .sample("NSRangeException", at: Date()),
                .sample("NSRangeException", at: Date().addingTimeInterval(-3600)),
            ]),
            breakdown: breakdown
        )
    }
    .environmentObject(Tint())
}
