//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct StatView: View {
    let showList: Bool

    @State var extent: ChartExtent<Period>
    @State private var isComparing = false
    @ObservedObject var stat: StatProvider
    @Environment(\.chartColor) var color

    var body: some View {
        ProviderView(provider: stat) { points in
            let segment = extent.segment(from: points)
            let canCompare = extent.canCompare(points: points, segment: segment)

            InsetList {
                PeriodPicker(extent: $extent, title: \.shortTitle)
                    .frame(minHeight: 44)

                RangeControl(extent: $extent)
                    .padding(.bottom)

                ComparableChart(
                    segment: segment,
                    points: points,
                    extent: extent,
                    color: color,
                    isComparing: isComparing
                )
                .padding(.bottom)

                ComparisonToggle(isOn: $isComparing)
                    .disabled(!canCompare)
                    .frame(minHeight: 44)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }

                if showList {
                    Row {
                        Text(verbatim: "Events")
                        Spacer()
                        RedactedText(count: segment.total)
                    } destination: {
                        EventStatList(eventName: stat.subject.name, range: extent.domain)
                    }
                    .foregroundStyle(.blue)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                }

                Header(title: "Weekly Pattern") {
                    Text(verbatim: "Last 4 weeks")
                        .font(.weight450(size: 13))
                        .foregroundStyle(.secondary)
                }

                HeatmapView(
                    grid: HeatmapGrid(
                        points: points,
                        range: HeatmapGrid.recentRange(weeks: 4),
                        calendar: .utc
                    )
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ChartExportButton(
                        title: stat.subject.name,
                        rangeLabel: extent.domain.label(using: rangeDateFormatter)
                    ) {
                        ChartView(segment: segment, timing: extent)
                            .foregroundStyle(color)
                    }
                }
            }
        }
        .resetsTint()
    }
}

extension EnvironmentValues {
    @Entry var chartColor: Color = .blue
}

#Preview("StatView") {
    NavigationStack {
        StatView(
            showList: true,
            extent: ChartExtent(period: .yesterday),
            stat: .init(.success([]), subject: .event("app_launch"))
        )
        .navigationTitle(en: "App Launch")
        .environmentObject(Tint())
    }
}
