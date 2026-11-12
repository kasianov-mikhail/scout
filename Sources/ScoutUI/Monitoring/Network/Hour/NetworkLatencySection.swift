//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkLatencyChart: View {
    let histogram: LatencyHistogram

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(histogram.networkBands) { band in
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        Color.clear
                            .frame(height: 64)

                        Rectangle()
                            .fill(band.isSlow ? Color.networkSlow : Color.networkTrack)
                            .frame(height: height(band))
                    }

                    Text(verbatim: band.label)
                        .font(.book(size: 10, design: .monospaced))
                        .foregroundStyle(Color(.systemGray))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 14)
    }

    private var maximum: Int {
        histogram.networkBands.map(\.count).max() ?? 0
    }

    private func height(_ band: NetworkLatencyBand) -> CGFloat {
        guard maximum > 0 else {
            return 0
        }
        guard band.count > 0 else {
            return 0
        }
        return max(3, 64 * CGFloat(band.count) / CGFloat(maximum))
    }
}

struct NetworkPercentileRow: View {
    let percentiles: Percentiles?

    var body: some View {
        HStack(spacing: 16) {
            item(label: "p50", value: percentiles?.p50.duration ?? "—", color: .primary, weight: .regular)
            item(label: "p90", value: percentiles?.p90.duration ?? "—", color: .primary, weight: .regular)
            item(label: "p99", value: percentiles.map(\.p99.duration) ?? "—", color: percentiles.map(\.p99.networkP99Color) ?? Color(.systemGray), weight: percentiles.map(\.p99.networkP99Weight) ?? .regular)
        }
        .font(.book(size: 12, design: .monospaced))
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private func item(label: String, value: String, color: Color, weight: Font.Weight) -> some View {
        HStack(spacing: 6) {
            Text(verbatim: label)
                .foregroundStyle(Color(.systemGray))
            Text(verbatim: value)
                .font(.weighted(size: 12, weight: weight, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}

struct NetworkLatencyBand: Identifiable {
    let index: Int
    let label: String
    let count: Int
    let isSlow: Bool

    var id: Int { index }
}

private struct LatencyBand {
    let label: String
    let indices: ClosedRange<Int>
    let isSlow: Bool
}

extension LatencyHistogram {
    var networkBands: [NetworkLatencyBand] {
        Self.bands.enumerated().map { index, band in
            let count = band.indices.reduce(0) { result, bucket in
                counts.indices.contains(bucket) ? result + counts[bucket] : result
            }
            return NetworkLatencyBand(index: index, label: band.label, count: count, isSlow: band.isSlow)
        }
    }

    private static let bands = [
        LatencyBand(label: "<100", indices: 0...6, isSlow: false),
        LatencyBand(label: "100", indices: 7...7, isSlow: false),
        LatencyBand(label: "250", indices: 8...8, isSlow: false),
        LatencyBand(label: "500", indices: 9...9, isSlow: false),
        LatencyBand(label: "1s", indices: 10...10, isSlow: true),
        LatencyBand(label: "2.5s", indices: 11...11, isSlow: true),
        LatencyBand(label: "5s", indices: 12...14, isSlow: true),
    ]
}
