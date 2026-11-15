//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct IncidentSummaryCardView: View {
    let card: IncidentSummaryCard
    let kind: IncidentKind

    var body: some View {
        VStack(alignment: .leading, spacing: .space4) {
            Text(verbatim: card.title)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)

            HStack(alignment: .top) {
                Text(verbatim: card.value)
                    .font(.scoutNumberM)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 8)

                if let change = card.change {
                    Text(verbatim: change)
                        .font(.scoutCaptionStrong)
                        .foregroundStyle(kind.textColor)
                        .lineLimit(1)
                        .padding(.top, .space2)
                }
            }
            .frame(height: 28)

            bars
                .padding(.top, .space4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bars: some View {
        let maximum = card.bars.max() ?? 0

        return HStack(alignment: .bottom, spacing: .space4) {
            ForEach(card.bars.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: .radiusBar)
                    .fill(kind.color)
                    .opacity(index == card.bars.count - 1 ? 1 : 0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: barHeight(card.bars[index], maximum: maximum))
            }
        }
        .frame(height: 52, alignment: .bottom)
    }

    private func barHeight(_ value: Double, maximum: Double) -> CGFloat {
        guard maximum > 0 else {
            return 3
        }
        return 3 + CGFloat(value / maximum) * 49
    }
}
