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
        HStack(spacing: .space8) {
            Text(verbatim: row.dayLabel)
                .font(.scoutRow)
                .frame(width: 64, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: .radiusBar)
                        .fill(Color.trendTrack)
                    RoundedRectangle(cornerRadius: .radiusBar)
                        .fill(Color.fillSuccess)
                        .frame(width: proxy.size.width * row.fraction)
                }
            }
            .frame(height: 8)

            Text(verbatim: row.valueLabel)
                .font(.scoutRowMono)
                .frame(width: 52, alignment: .trailing)

            Text(verbatim: row.deltaLabel)
                .font(.scoutCaption)
                .foregroundStyle(row.isRising ? Color.trendPositive : Color.fillLevel)
                .frame(width: 52, alignment: .trailing)
        }
        .frame(height: .rowTable)
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

    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(series.rows) { row in
                ActivityDayRow(row: row)
            }
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}
