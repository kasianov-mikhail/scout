//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionDayRow: View {
    let value: RetentionDayValue
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: value.day.title)
                .font(.weight450(size: 15))
                .frame(width: 52, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(value.rate == nil ? Color(.systemGray6) : Color(.systemGray5))

                    LeftRoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: proxy.size.width * value.fraction)
                }
                .overlay(alignment: .leading) {
                    if let average = value.averageFraction {
                        Rectangle()
                            .fill(value.rate == nil ? Color(.systemGray) : Color.primary)
                            .frame(width: 2, height: 24)
                            .offset(x: min(proxy.size.width * average, proxy.size.width - 2))
                    }
                }
            }
            .frame(height: 18)

            RetentionValueLabel(kept: value.keptLabel, rate: value.rateLabel, pending: value.pendingLabel)
                .frame(width: 76, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }
}

#Preview {
    let rates: [Double?] = [0.43, 0.29, 0.2, nil, nil]

    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(RetentionDay.allCases.enumerated()), id: \.element) { index, day in
                RetentionDayRow(
                    value: RetentionDayValue(day: day, size: 960, rate: rates[index], average: 0.2, pending: "in 2 d"),
                    showsDivider: day != .day30
                )
            }
        }
        .padding(.horizontal, 16)
    }
    .scrollIndicators(.hidden)
}
