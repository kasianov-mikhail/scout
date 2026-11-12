//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TrendCard: View {
    let title: String
    let color: Color
    let trend: Trend?
    let risesAreBad: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .space4) {
            Text(verbatim: title.uppercased())
                .font(.scoutCaption)
                .foregroundStyle(Color.textSecondary)
                .padding(.leading, .space2)

            HStack(alignment: .top) {
                ZStack(alignment: .leading) {
                    Text(verbatim: "0").hidden()

                    if let count = trend?.count {
                        Text(count == 0 ? "—" : count.compact)
                    } else if trend != nil {
                        Redacted(length: 5).font(.scoutBody)
                    } else {
                        Text(verbatim: "0")
                    }
                }
                .font(.scoutNumberM)

                Spacer()

                if let delta = trend?.delta {
                    Text(verbatim: delta.formatted)
                        .font(.scoutCaptionStrong)
                        .foregroundStyle(delta.isFavorable(risesAreBad: risesAreBad) ? Color.textSuccess : Color.textDanger)
                        .padding(.top, .space2)
                }
            }

            Spacer().frame(height: 4)

            Group {
                if let series = trend?.series {
                    Sparkline(series: series, color: color)
                } else {
                    Sparkline(series: .empty, color: color)
                }
            }
            .frame(height: 68)
        }
    }
}

#Preview("TrendCard") {
    let columns = [GridItem(.fixed(162), spacing: .space24), GridItem(.fixed(162), spacing: .space24)]

    LazyVGrid(columns: columns, spacing: .space24) {
        TrendCard(
            title: "Sessions",
            color: .purple,
            trend: Trend(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12]),
            risesAreBad: false
        )
        TrendCard(
            title: "Crashes",
            color: .fillDanger,
            trend: Trend(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4]),
            risesAreBad: true
        )
        TrendCard(
            title: "Empty",
            color: .fillDanger,
            trend: Trend(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0]),
            risesAreBad: true
        )
        TrendCard(
            title: "Loading",
            color: .fillSuccess,
            trend: .loading,
            risesAreBad: false
        )
        TrendCard(
            title: "Missing",
            color: .fillSuccess,
            trend: nil,
            risesAreBad: false
        )
    }
    .padding()
}
