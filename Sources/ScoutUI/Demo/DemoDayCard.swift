//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DemoDayCard: View {
    let day: DemoDay
    let isSelected: Bool

    var body: some View {
        HStack(spacing: .space12) {
            VStack(alignment: .leading, spacing: .space2) {
                Text(verbatim: day.title)
                    .font(.scoutTitle)
                    .lineLimit(1)
                    .frame(height: 22)

                Text(verbatim: day.detail)
                    .font(.scoutRow)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .frame(height: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            DemoDayBars(bars: day.bars, highlight: day.highlight)
        }
        .padding(.horizontal, 14)
        .frame(height: 76)
        .background(isSelected ? Color.surfaceSelected : Color.surface, in: RoundedRectangle(cornerRadius: .radiusBlock))
        .overlay {
            RoundedRectangle(cornerRadius: .radiusBlock)
                .strokeBorder(isSelected ? Color.fillAccent : Color.lineSeparator, lineWidth: isSelected ? .ruleThick : .hairline)
        }
        .contentShape(RoundedRectangle(cornerRadius: .radiusBlock))
    }
}

private struct DemoDayBars: View {
    let bars: [CGFloat]
    let highlight: DemoDay.Highlight?

    var body: some View {
        HStack(alignment: .bottom, spacing: .space2) {
            ForEach(bars.indices, id: \.self) { index in
                bar(at: index)
            }
        }
        .frame(height: 28, alignment: .bottom)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func bar(at index: Int) -> some View {
        switch tone(at: index) {
        case .danger:
            barShape.fill(Color.fillDanger).frame(width: 4, height: bars[index])
        case .outage:
            Stripes()
                .fill(Color.fillWarning)
                .frame(width: 4, height: bars[index])
                .clipShape(RoundedRectangle(cornerRadius: 1))
        case nil:
            barShape.fill(Color.surfaceBarIdle).frame(width: 4, height: bars[index])
        }
    }

    private var barShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 1)
    }

    private func tone(at index: Int) -> DemoDay.Tone? {
        guard let highlight, highlight.range.contains(index) else {
            return nil
        }
        return highlight.tone
    }
}
