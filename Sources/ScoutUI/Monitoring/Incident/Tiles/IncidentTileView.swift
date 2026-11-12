//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentTileView<Element: Incident>: View {
    enum Side {
        case leading
        case trailing
    }

    let tile: IncidentTile<Element>
    let side: Side

    var body: some View {
        VStack(alignment: .leading, spacing: .space6) {
            headline

            Text(verbatim: tile.name)
                .font(.scoutValue)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)

            Text(verbatim: tile.subtitle)
                .font(.scoutMonoCaption)
                .foregroundStyle(Color.textMuted)
                .lineLimit(1)

            bars
                .padding(.top, .space4)
        }
        .padding(.top, .space16)
        .padding(.bottom, .space12)
        .padding(.leading, side == .trailing ? 14 : 0)
        .padding(.trailing, side == .leading ? 14 : 0)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var headline: some View {
        HStack(alignment: .firstTextBaseline, spacing: .space8) {
            Text(verbatim: "\(tile.count)")
                .font(.scoutNumberXL)
                .foregroundStyle(tile.isAccented ? Element.kind.detailColor : Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: 34, alignment: .leading)

            if let change = tile.changeLabel {
                Text(verbatim: change)
                    .font(.scoutCaptionStrong)
                    .foregroundStyle(tile.isAccented ? Element.kind.detailColor : Color.fillLevel)
                    .lineLimit(1)
            }
        }
    }

    private var bars: some View {
        let maxValue = max(tile.bars.max() ?? 0, 1)

        return HStack(alignment: .bottom, spacing: .space2) {
            ForEach(Array(tile.bars.enumerated()), id: \.offset) { index, value in
                barShape
                    .fill(fill(value: value, index: index))
                    .frame(maxWidth: .infinity)
                    .frame(height: barHeight(value: value, maxValue: maxValue))
            }
        }
        .frame(height: 28)
        .accessibilityHidden(true)
    }

    private var barShape: AnyShape {
        if #available(iOS 17.0, macOS 14.0, *) {
            AnyShape(UnevenRoundedRectangle(topLeadingRadius: 1.5, topTrailingRadius: 1.5))
        } else {
            AnyShape(RoundedRectangle(cornerRadius: .radiusBar))
        }
    }

    private func barHeight(value: Int, maxValue: Int) -> CGFloat {
        guard value > 0 else {
            return 2
        }
        return max(2, 28 * CGFloat(value) / CGFloat(maxValue))
    }

    private func fill(value: Int, index: Int) -> Color {
        if index == tile.bars.count - 1, tile.todayCount > 0 {
            return Element.kind.color
        }
        if value == 0 {
            return Color.surfaceBarIdle
        }
        return Color.fillLevel.opacity(0.2)
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            IncidentGrid(count: IncidentTile<Crash>.samples.count) { index in
                IncidentTileView(
                    tile: IncidentTile<Crash>.samples[index],
                    side: index.isMultiple(of: 2) ? .leading : .trailing
                )
            }
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
    .navigationTitle(en: "Crashes")
}
