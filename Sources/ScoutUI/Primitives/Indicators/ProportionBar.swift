//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ProportionBar<Item: Identifiable>: View {
    let items: [Item]
    let color: (Int, Item) -> Color
    let share: (Item) -> Double

    var body: some View {
        GeometryReader { proxy in
            let gaps = CGFloat(max(items.count - 1, 0)) * 2
            let width = max(proxy.size.width - gaps, 0)

            HStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Rectangle()
                        .fill(color(index, item))
                        .frame(width: width * CGFloat(share(item)))
                }
            }
        }
        .frame(height: 10)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct BarValue: View {
    let text: String
    let fraction: Double
    let color: Color
    var barHeight: CGFloat?
    var minimumWidth: CGFloat = 0

    var body: some View {
        Text(verbatim: text)
            .font(.system(size: 13, design: .monospaced))
            .monospacedDigit()
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .leading) {
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: max(proxy.size.width * CGFloat(fraction), fraction > 0 ? minimumWidth : 0), height: barHeight)
                }
            }
    }
}

#Preview {
    VStack(spacing: 24) {
        ProportionBar(
            items: PreviewItem.samples,
            color: { _, item in item.color },
            share: \.share
        )

        BarValue(text: "4,100", fraction: 0.7, color: .cyan)
    }
    .padding()
}

private struct PreviewItem: Identifiable {
    let id: Int
    let share: Double
    let color: Color

    static let samples: [PreviewItem] = [
        PreviewItem(id: 0, share: 0.5, color: .blue),
        PreviewItem(id: 1, share: 0.3, color: .cyan),
        PreviewItem(id: 2, share: 0.2, color: .gray),
    ]
}
