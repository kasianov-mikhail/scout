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
                .font(.weight450(size: 15))
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
                .font(.weight450(size: 15, design: .monospaced))
                .frame(width: 52, alignment: .trailing)

            Text(verbatim: row.deltaLabel)
                .font(.weight450(size: 13))
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
                .frame(minHeight: 44)
        }
    }
}
