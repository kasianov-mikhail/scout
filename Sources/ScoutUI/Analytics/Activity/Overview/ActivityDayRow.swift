//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ActivityDayRow: View {
    let row: ActivityRow

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: row.dayLabel)
                .font(.system(size: 15))
                .frame(width: 64, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.trendTrack)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * row.fraction)
                }
            }
            .frame(height: 8)

            Text(verbatim: row.valueLabel)
                .font(.system(size: 15, design: .monospaced))
                .frame(width: 52, alignment: .trailing)

            Text(verbatim: row.deltaLabel)
                .font(.system(size: 13))
                .foregroundStyle(row.isRising ? Color.trendPositive : Color(.systemGray))
                .frame(width: 52, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            if !row.isOldest {
                DashedLine()
            }
        }
    }
}

struct DashedLine: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0.25))
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0.25))
            }
            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
        }
        .frame(height: 0.5)
    }
}

#Preview {
    let series = ActivitySeries(
        points: ActivityPoint.samples,
        range: .month,
        metric: .daily,
        now: Date()
    )

    InsetList {
        ForEach(series.rows) { row in
            ActivityDayRow(row: row)
        }
    }
}
