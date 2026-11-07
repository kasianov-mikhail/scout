//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

private let exitShades: [Color] = [Color(.systemGray), Color(.systemGray2), Color(.systemGray3), Color(.systemGray4)]

enum VersionMetricChart {
    case stability(Stability)
    case adoption(Adoption)
    case bars([Int], color: Color?)
    case exits([ExitShare])
}

struct VersionMetricChartView: View {
    let chart: VersionMetricChart

    var body: some View {
        switch chart {
        case .stability(let stability):
            StabilityScaleBar(stability: stability)
        case .adoption(let adoption):
            AdoptionProgressBar(adoption: adoption)
        case .bars(let values, let color):
            MetricBars(values: values, color: color)
        case .exits(let shares):
            ExitShareStack(shares: shares)
        }
    }
}

private struct StabilityScaleBar: View {
    let stability: Stability

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Color.stabilityCritical
                        .frame(width: proxy.size.width / 2)

                    Color.stabilityWatch
                        .frame(width: proxy.size.width / 4)

                    Color.stabilityHealthy
                        .frame(width: proxy.size.width / 4)
                }
                .frame(height: 6)

                Rectangle()
                    .fill(.black)
                    .frame(width: 2, height: 6)
                    .offset(x: min(proxy.size.width * stability.markerPosition, proxy.size.width - 2))
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .clipShape(Capsule())
        }
        .frame(height: 24)
        .accessibilityHidden(true)
    }
}

private struct AdoptionProgressBar: View {
    let adoption: Adoption

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 6)

                Capsule()
                    .fill(Color(.systemGray2))
                    .frame(width: proxy.size.width * adoption.value, height: 6)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 24)
        .accessibilityHidden(true)
    }
}

private struct MetricBars: View {
    let values: [Int]
    let color: Color?

    var body: some View {
        let top = values.max() ?? 0

        return HStack(alignment: .bottom, spacing: 2) {
            ForEach(values.indices, id: \.self) { index in
                Rectangle()
                    .fill(fill(index: index, value: values[index]))
                    .frame(maxWidth: .infinity)
                    .frame(height: height(value: values[index], top: top))
            }
        }
        .frame(height: 24, alignment: .bottom)
        .accessibilityHidden(true)
    }

    private func height(value: Int, top: Int) -> CGFloat {
        guard value > 0, top > 0 else {
            return 1
        }

        return max(1, (Double(value) / Double(top) * 24).rounded())
    }

    private func fill(index: Int, value: Int) -> Color {
        if value == 0 {
            return Color(.systemGray5)
        }

        guard index == values.count - 1, let color else {
            return Color(.systemGray4)
        }

        return color
    }
}

private struct ExitShareStack: View {
    let shares: [ExitShare]

    var body: some View {
        GeometryReader { proxy in
            let total = shares.map(\.count).reduce(0, +)
            let gaps = CGFloat(max(shares.count - 1, 0)) * 2
            let width = max(proxy.size.width - gaps, 0)

            HStack(spacing: 2) {
                ForEach(shares.indices, id: \.self) { index in
                    Rectangle()
                        .fill(exitShades[min(index, exitShades.count - 1)])
                        .frame(width: total > 0 ? width * CGFloat(shares[index].count) / CGFloat(total) : 0)
                }
            }
            .frame(height: 6)
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 24)
        .accessibilityHidden(true)
    }
}
