//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct Sparkline: View {
    let series: MiniChartSeries
    let color: Color
    var lineWidth: Double = 2
    var showsGridlines = true
    var gridlinesAtPoints = false

    var body: some View {
        let values = series.isEmpty ? [] : series.values
        let scale = SparklineScale(values: values)
        let last = Double(max(values.count - 1, 1))
        let xGridlines =
            gridlinesAtPoints
            ? Array(stride(from: 0, through: last, by: 1))
            : (0...3).map { last * Double($0) / 3 }

        Chart(Array(values.enumerated()), id: \.offset) { index, value in
            AreaMark(
                x: .value("Slice", Double(index)),
                yStart: .value("Bottom", scale.bottom),
                yEnd: .value("Count", Double(value))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(
                x: .value("Slice", Double(index)),
                y: .value("Count", Double(value))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .chartXAxis {
            if showsGridlines {
                AxisMarks(values: xGridlines) { _ in
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            if showsGridlines {
                AxisMarks(values: [scale.bottom, scale.top]) { _ in
                    AxisGridLine()
                }
            }
        }
        .chartXScale(domain: 0...last)
        .chartYScale(domain: scale.domain)
        .chartLegend(.hidden)
    }
}

#Preview {
    VStack(spacing: 24) {
        Sparkline(series: MiniChartSeries(values: [3, 5, 4, 7, 6, 9, 12]), color: .purple)
            .frame(height: 60)
        Sparkline(series: MiniChartSeries(values: [9, 7, 8, 6, 7, 5, 4]), color: .red)
            .frame(height: 60)
        Sparkline(series: MiniChartSeries(values: [4, 4, 4, 4, 4, 4, 4]), color: .green)
            .frame(height: 60)
        Sparkline(series: .empty, color: .orange)
            .frame(height: 60)
    }
    .padding()
}
