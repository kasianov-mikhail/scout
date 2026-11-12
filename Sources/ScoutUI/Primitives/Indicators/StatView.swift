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

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    PeriodPicker(extent: $extent, title: \.shortTitle)

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
                        .overlay(alignment: .bottom) {
                            Separator()
                        }

                    if showList {
                        NavigationLink {
                            EventStatList(eventName: stat.subject.name, range: extent.domain)
                        } label: {
                            HStack(spacing: 8) {
                                Text(verbatim: "Events")
                                Spacer()
                                RedactedText(count: segment.total)
                            }
                            .lineLimit(1)
                            .frame(height: 44)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
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
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
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
