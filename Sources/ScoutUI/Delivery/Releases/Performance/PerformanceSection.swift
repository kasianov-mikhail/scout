//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct PerformanceSection: View {
    let version: String
    let comparison: PerformanceComparison

    @ViewBuilder
    var body: some View {
        if !comparison.current.isEmpty {
            Header(title: "Performance")

            HStack(spacing: 28) {
                ForEach(comparison.readouts) { readout in
                    Readout(readout: readout)
                }
                Spacer()
            }

            LaunchChart(bars: comparison.launchBars(version: version), version: version)
                .padding(.vertical, 16)
                .listRowSeparator(.hidden, edges: .bottom)
        }
    }
}

extension PerformanceSection {
    init(release: ReleaseHealth) {
        self.init(version: release.id, comparison: release.performance)
    }
}

extension Readout {
    fileprivate init(readout: PerformanceReadout) {
        self.init(title: readout.title, value: readout.value ?? "–", color: readout.color)
    }
}

private struct LaunchChart: View {
    let bars: [LaunchBar]
    let version: String

    var body: some View {
        Chart(bars) { bar in
            BarMark(
                x: .value("Launch time", bar.category),
                y: .value("Launches", bar.share)
            )
            .foregroundStyle(by: .value("Version", bar.version))
            .position(by: .value("Version", bar.version))
        }
        .chartForegroundStyleScale { (name: String) in
            name == version ? Color.blue : Color.gray.opacity(0.5)
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self).flatMap(LaunchBar.axisLabel) {
                        Text(verbatim: label)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartLegend(position: .top, alignment: .leading)
        .frame(height: 113)
    }
}

#Preview {
    InsetList {
        PerformanceSection(version: "3.2.0", comparison: .sample)
    }
}

#Preview("Without a previous version") {
    InsetList {
        PerformanceSection(version: "3.2.0", comparison: PerformanceComparison(current: .sample, previous: nil))
    }
}
