//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ScoutCore
import SwiftUI

struct IncidentBreakdownSection<Element: Incident, RowContent: View>: View {
    let breakdown: IncidentBreakdown
    let records: [Element]
    @ViewBuilder let row: (Element) -> RowContent

    var body: some View {
        if breakdown.devices.count > 0 {
            Header(title: "Top Devices")
            chart(for: .devices, segments: breakdown.devices, caption: "devices")
                .listRowSeparator(.hidden, edges: .bottom)
        }

        if breakdown.osVersions.count > 0 {
            Header(title: "OS Versions")
            chart(for: .osVersions, segments: breakdown.osVersions, caption: "sessions")
                .listRowSeparator(.hidden, edges: .bottom)
        }
    }

    @ViewBuilder
    private func chart(for dimension: IncidentBreakdown.Dimension, segments: [Segment], caption: String) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            IncidentDonut(segments: segments, caption: caption) { segment in
                matches(in: dimension, segment: segment).count
            } destination: { segment in
                SegmentOccurrenceList(
                    title: segment.label,
                    records: matches(in: dimension, segment: segment),
                    row: row
                )
            }
        } else {
            SegmentBar(segments: segments)
        }
    }

    private func matches(in dimension: IncidentBreakdown.Dimension, segment: Segment) -> [Element] {
        breakdown.records(from: records, in: dimension, matching: segment)
    }
}

#Preview {
    NavigationStack {
        List {
            IncidentBreakdownSection(breakdown: .sample, records: [Crash].samples) { crash in
                Row {
                    if let date = crash.date {
                        UTCTimestampText(date: date, size: 14)
                    }
                } destination: {
                    CrashDetailView(crash: crash)
                }
            }
        }
        .listStyle(.plain)
    }
    .environmentObject(Tint())
}
