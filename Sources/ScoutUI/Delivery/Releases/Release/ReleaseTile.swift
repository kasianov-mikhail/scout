//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseTile: View {
    let value: ReleaseTileValue
    let isLeading: Bool
    let action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .releaseGridCell(isLeading: isLeading)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: value.kind.title)
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))

            Text(verbatim: value.value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(value.color)

            ReleaseChartView(chart: value.chart)
                .frame(height: 24)

            if let footer = value.footer {
                Text(verbatim: footer)
                    .font(.weight450(size: 12))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
    }
}

extension View {
    func releaseGridCell(isLeading: Bool) -> some View {
        padding(.vertical, 14)
            .padding(.leading, isLeading ? 0 : 12)
            .padding(.trailing, isLeading ? 12 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .overlay(alignment: .trailing) {
                if isLeading {
                    Rectangle()
                        .fill(Color.separator)
                        .frame(width: 0.5)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
    }
}

private struct ReleaseChartView: View {
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
                        .fill(Color(red: 0xFF / 255, green: 0xE5 / 255, blue: 0xE5 / 255))
                        .frame(width: width * 0.5)

                    Rectangle()
                        .fill(Color(red: 0xFF / 255, green: 0xF3 / 255, blue: 0xD6 / 255))
                        .frame(width: width * 0.25)

                    Rectangle()
                        .fill(Color(red: 0xE3 / 255, green: 0xF5 / 255, blue: 0xE8 / 255))
                        .frame(width: width * 0.25)
                }

                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2)
                    .offset(x: min(max(width * fraction, width * 0.005), width - 2))
            }
            .frame(height: 6)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .position(x: width / 2, y: proxy.size.height / 2)
        }
    }

    private func progress(_ value: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray2))
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
            .frame(height: 6)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }

    private func bars(_ values: [Int], accent: Color?) -> some View {
        let maximum = values.max() ?? 0

        return HStack(alignment: .bottom, spacing: 2) {
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
        return value > 0 ? Color(.systemGray4) : Color(.systemGray5)
    }

    private func segments(_ values: [Double]) -> some View {
        let total = values.reduce(0, +)

        return GeometryReader { proxy in
            let gaps = CGFloat(max(values.count - 1, 0)) * 2
            let room = max(proxy.size.width - gaps, 0)

            HStack(spacing: 2) {
                ForEach(values.indices, id: \.self) { index in
                    Rectangle()
                        .fill(shade(index))
                        .frame(width: total > 0 ? room * CGFloat(values[index] / total) : 0)
                }
            }
            .frame(height: 6)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }

    private func shade(_ index: Int) -> Color {
        switch index {
        case 0: Color(.systemGray)
        case 1: Color(.systemGray2)
        case 2: Color(.systemGray3)
        default: Color(.systemGray4)
        }
    }
}

#Preview {
    let release = [ReleaseHealth].samples[0]
    let detail = ReleaseDetail(release: release, trend: .sample, now: Date())

    VStack(spacing: 0) {
        HStack(spacing: 0) {
            ReleaseTile(value: detail.tiles[0], isLeading: true, action: nil)
            ReleaseTile(value: detail.tiles[1], isLeading: false, action: nil)
        }
        HStack(spacing: 0) {
            ReleaseTile(value: detail.tiles[2], isLeading: true, action: {})
            ReleaseTile(value: detail.tiles[3], isLeading: false, action: {})
        }
    }
    .padding(.horizontal, 16)
}
