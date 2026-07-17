//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import Scout
import SwiftUI

extension [Segment] {
    var total: Int {
        reduce(0) { $0 + $1.count }
    }

    func segment(at angle: Double) -> Segment? {
        var cumulative = 0
        for segment in self {
            cumulative += segment.count
            if angle < Double(cumulative) { return segment }
        }
        return last
    }

    func percent(of segment: Segment) -> String {
        let total = self.total
        guard total > 0 else { return "0%" }
        return "\(Int((Double(segment.count) / Double(total) * 100).rounded()))%"
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct IncidentDonut<Destination: View>: View {
    let segments: [Segment]
    let caption: String
    let drillDownCount: (Segment) -> Int
    @ViewBuilder let destination: (Segment) -> Destination

    @State private var angle: Double?
    @State private var selected: Segment?

    var body: some View {
        VStack(spacing: 12) {
            chart

            if let selected {
                drillDownLink(for: selected)
            } else {
                legend.padding(.vertical, 10)
            }
        }
    }

    private var chart: some View {
        Chart(segments) { segment in
            SectorMark(
                angle: .value("Count", segment.count),
                innerRadius: .ratio(0.618),
                outerRadius: .ratio(selected == segment ? 1.0 : 0.92),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(segment.color)
            .opacity(selected == nil || selected == segment ? 1 : 0.3)
        }
        .chartAngleSelection(value: $angle)
        .frame(height: 190)
        .overlay { center }
        .onChange(of: angle) { _, angle in
            guard let angle else { return }
            let hit = segments.segment(at: angle)
            selected = hit == selected ? nil : hit
        }
        .animation(.snappy(duration: 0.25), value: selected)
    }

    private var center: some View {
        VStack(spacing: 2) {
            Text(verbatim: "\(selected?.count ?? segments.total)")
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(selected?.color ?? .primary)
            Text(verbatim: selected.map(segments.percent) ?? caption)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }

    private var legend: some View {
        HStack(spacing: 16) {
            ForEach(segments) { segment in
                HStack(spacing: 5) {
                    Circle().fill(segment.color).frame(width: 7, height: 7)
                    Text(verbatim: segment.label)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    private func drillDownLink(for segment: Segment) -> some View {
        NavigationLink {
            destination(segment)
        } label: {
            HStack {
                Text(verbatim: "Show \(ExportFormat.counted(drillDownCount(segment), .occurrence)) · \(segment.label)")
                    .font(.footnote.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundStyle(segment.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(segment.color.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Devices") {
    if #available(iOS 17.0, macOS 14.0, *) {
        NavigationStack {
            IncidentDonut(segments: IncidentBreakdown.sample.devices, caption: "devices") { segment in
                segment.count
            } destination: { segment in
                Text(verbatim: segment.label)
            }
            .padding()
        }
    }
}

#Preview("OS Versions") {
    if #available(iOS 17.0, macOS 14.0, *) {
        NavigationStack {
            IncidentDonut(segments: IncidentBreakdown.sample.osVersions, caption: "sessions") { segment in
                segment.count
            } destination: { segment in
                Text(verbatim: segment.label)
            }
            .padding()
        }
    }
}
