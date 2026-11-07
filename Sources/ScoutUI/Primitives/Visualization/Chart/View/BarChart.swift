//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct BarChart: View {
    struct Accent {
        let index: Int
        let color: Color
    }

    let values: [Int]
    let startLabel: String
    let middleLabel: String?
    let endLabel: String
    let height: CGFloat
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let labelGap: CGFloat
    let labelDesign: Font.Design
    let accent: Accent?

    var body: some View {
        let maximum = values.max() ?? 0

        return VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(values.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(color(index: index))
                        .frame(maxWidth: .infinity)
                        .frame(height: barHeight(value: values[index], maximum: maximum))
                }
            }
            .frame(height: height, alignment: .bottom)

            AxisLabelRow(
                start: startLabel,
                middle: middleLabel,
                end: endLabel,
                topInset: labelGap,
                design: labelDesign
            )
        }
    }

    private func color(index: Int) -> Color {
        guard let accent, accent.index == index else {
            return Color(.systemGray4)
        }
        return accent.color
    }

    private func barHeight(value: Int, maximum: Int) -> CGFloat {
        guard maximum > 0 else {
            return 0
        }
        return CGFloat(value) / CGFloat(maximum) * height
    }
}

struct AxisLabelRow: View {
    let start: String
    let middle: String?
    let end: String
    let topInset: CGFloat
    let design: Font.Design

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: start)

            Spacer()

            if let middle {
                Text(verbatim: middle)
                Spacer()
            }

            Text(verbatim: end)
        }
        .font(.system(size: 10, design: design))
        .foregroundStyle(Color(.systemGray))
        .padding(.top, topInset)
    }
}

#Preview {
    BarChart(
        values: [10, 14, 9, 12, 18, 15, 20],
        startLabel: "Sep 26",
        middleLabel: "Oct 10",
        endLabel: "today",
        height: 72,
        spacing: 2,
        cornerRadius: 1,
        labelGap: 4,
        labelDesign: .default,
        accent: .init(index: 6, color: .green)
    )
    .padding()
}
