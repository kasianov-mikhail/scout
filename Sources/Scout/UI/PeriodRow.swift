//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PeriodRow: View {
    let period: Period
    let color: Color
    @ObservedObject var stat: StatProvider

    var body: some View {
        ZStack {
            HStack {
                Text(period.title)
                Spacer()

                let model = StatModel(period: period)
                let count = model.points(from: stat.data)?.count

                RedactedText(count: count)
            }
            .foregroundColor(color)

            NavigationLink {
                StatView(
                    stat: stat,
                    period: period,
                    chartColor: color,
                    showFooter: color == .blue
                )
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }
}
