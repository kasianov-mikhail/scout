//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseChartView: View {
    let chart: ReleaseChart

    var body: some View {
        switch chart {
        case .zones(let value):
            zones(value)
        case .progress(let value):
            progress(value)
        case .bars(let values, let accent):
            bars(values, accent: accent)
        case .segments(let values):
            segments(values)
        }
    }

    private func zones(_ value: Double) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let fraction = min(max((value - 0.98) / 0.02, 0), 1)

            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.tintDanger)
                        .frame(width: width * 0.5)

                    Rectangle()
                        .fill(Color.tintWarning)
                        .frame(width: width * 0.25)

                    Rectangle()
                        .fill(Color.tintSuccess)
                        .frame(width: width * 0.25)
                }

                Rectangle()
                    .fill(Color.textPrimary)
                    .frame(width: 2)
                    .offset(x: min(max(width * fraction, width * 0.005), width - 2))
                    .animation(.barResize, value: fraction)
            }
            .frame(height: 6)
            .clipShape(RoundedRectangle(cornerRadius: .radiusBlock))
            .position(x: width / 2, y: proxy.size.height / 2)
        }
    }

    private func progress(_ value: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .radiusBlock)
                    .fill(Color.surfaceSkeleton)

                RoundedRectangle(cornerRadius: .radiusBlock)
                    .fill(Color.textMuted)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
                    .animation(.barResize, value: value)
            }
            .frame(height: 6)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }

    private func bars(_ values: [Int], accent: Color?) -> some View {
        let maximum = values.max() ?? 0

        return HStack(alignment: .bottom, spacing: .space2) {
            ForEach(values.indices, id: \.self) { index in
                let value = values[index]
                let isLast = index == values.count - 1
                let height = maximum > 0 ? max(24 * Double(value) / Double(maximum), 1) : 1

                Rectangle()
                    .fill(fill(value: value, isLast: isLast, accent: accent))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            }
        }
        .frame(height: 24, alignment: .bottom)
    }

    private func fill(value: Int, isLast: Bool, accent: Color?) -> Color {
        if isLast, let accent, value > 0 {
            return accent
        }
        return value > 0 ? Color.surfaceBarIdle : Color.surfaceSkeleton
    }

    private func segments(_ values: [Double]) -> some View {
        let total = values.reduce(0, +)

        return GeometryReader { proxy in
            let gaps = CGFloat(max(values.count - 1, 0)) * 2
            let room = max(proxy.size.width - gaps, 0)

            HStack(spacing: .space2) {
                ForEach(values.indices, id: \.self) { index in
                    Rectangle()
                        .fill(shade(index))
                        .frame(width: total > 0 ? room * CGFloat(values[index] / total) : 0)
                }
            }
            .frame(height: 6)
            .animation(.barResize, value: values)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }

    private func shade(_ index: Int) -> Color {
        switch index {
        case 0: Color.fillLevel
        case 1: Color.textMuted
        case 2: Color.lineSeparator
        default: Color.surfaceBarIdle
        }
    }
}
