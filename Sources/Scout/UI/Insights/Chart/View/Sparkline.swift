//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct SparklineStyle {
    let lineWidth: Double
    let columns: Int

    static let card = SparklineStyle(lineWidth: 2, columns: 3)
    static let row = SparklineStyle(lineWidth: 1.5, columns: 1)
}

struct Sparkline: View {
    let series: MiniChartSeries
    let color: Color
    var style: SparklineStyle = .card

    var body: some View {
        let values = series.isEmpty ? [] : series.values
        let scale = SparklineScale(values: values)
        let last = Double(max(values.count - 1, 1))

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
            .lineStyle(StrokeStyle(lineWidth: style.lineWidth, lineCap: .round))
        }
        .chartXAxis {
            AxisMarks(values: (0...style.columns).map { last * Double($0) / Double(style.columns) }) { _ in
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(values: [scale.bottom]) { _ in
                AxisGridLine()
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
