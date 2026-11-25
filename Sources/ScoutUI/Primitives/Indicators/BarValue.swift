//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct BarValue: View {
    let text: String
    let fraction: Double
    let color: Color
    var barHeight: CGFloat?
    var minimumWidth: CGFloat = 0

    var body: some View {
        if let barHeight {
            label
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: barHeight)
                .background(alignment: .leading) {
                    GeometryReader { proxy in
                        bar(width: proxy.size.width, height: barHeight)
                    }
                }
        } else {
            label
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(alignment: .leading) {
                    GeometryReader { proxy in
                        bar(width: proxy.size.width, height: proxy.size.height)
                    }
                }
        }
    }

    private var label: some View {
        Text(verbatim: text)
            .font(.scoutValue)
            .monospacedDigit()
            .padding(.horizontal, .space4)
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: .radiusBlock)
            .fill(color)
            .frame(width: max(width * CGFloat(fraction), fraction > 0 ? minimumWidth : 0), height: height)
            .animation(.barResize, value: fraction)
    }
}

#Preview {
    VStack(spacing: .space16) {
        BarValue(text: "4,100", fraction: 0.7, color: .cyan)

        BarValue(text: "4,100", fraction: 0.7, color: .fillAccent, barHeight: 28)
            .frame(width: 200)
            .frame(height: 18)
    }
    .padding()
}
