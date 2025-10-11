//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

typealias StatConfig = StatView.Config

struct StatRow: View {
    let config: StatConfig
    let period: Period

    @ObservedObject var stat: StatProvider

    var body: some View {
        Row {
            Group {
                Text(period.title)
                Spacer()

                let count = ChartModel(period: period)
                    .segment(from: stat.data)?
                    .total

                RedactedText(count: count)
            }
            .foregroundColor(config.color)
        } destination: {
            StatView(config: config, stat: stat, period: period)
        }
    }
}
