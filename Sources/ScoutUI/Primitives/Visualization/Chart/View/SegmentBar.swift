//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import Scout
import SwiftUI

struct Segment: Identifiable, Equatable {
    enum Kind: Equatable {
        case value(String)
        case other
    }

    let count: Int
    let color: Color
    let kind: Kind

    init(label: String, count: Int, color: Color) {
        self.init(count: count, color: color, kind: .value(label))
    }

    init(count: Int, color: Color, kind: Kind) {
        self.count = count
        self.color = color
        self.kind = kind
    }

    var label: String {
        switch kind {
        case .value(let label): label
        case .other: "Other"
        }
    }

    var value: String? {
        switch kind {
        case .value(let label): label
        case .other: nil
        }
    }

    var id: String {
        switch kind {
        case .value(let label): "value:\(label)"
        case .other: "other"
        }
    }
}

extension String {
    var captionWidth: CGFloat {
        #if os(iOS)
            let font = UIFont.preferredFont(forTextStyle: .caption1)
        #else
            let font = NSFont.preferredFont(forTextStyle: .caption1)
        #endif
        return (self as NSString).size(withAttributes: [.font: font]).width
    }
}

extension [Segment] {
    func fittingLegend(width: CGFloat, spacing: CGFloat, chipWidth: (Segment) -> CGFloat) -> [Segment] {
        var named = filter { $0.kind != .other }
        var otherCount = first { $0.kind == .other }?.count ?? 0

        func candidate() -> [Segment] {
            otherCount > 0 ? named + [Segment(count: otherCount, color: .gray, kind: .other)] : named
        }

        while named.count > 1 {
            let current = candidate()
            let chips = current.reduce(0) { $0 + chipWidth($1) }
            let gaps = spacing * CGFloat(Swift.max(current.count - 1, 0))

            if chips + gaps <= width {
                break
            }
            otherCount += named.removeLast().count
        }

        return candidate()
    }
}

struct SegmentBar: View {
    let segments: [Segment]

    private static let legendSpacing: CGFloat = 16
    private static let dotWidth: CGFloat = 7
    private static let dotSpacing: CGFloat = 5

    var body: some View {
        GeometryReader { proxy in
            content(fitted: fitted(in: proxy.size.width))
                .frame(maxHeight: .infinity)
        }
        .frame(height: 78)
    }

    private func fitted(in width: CGFloat) -> [Segment] {
        segments.fittingLegend(width: width, spacing: Self.legendSpacing) { segment in
            Self.dotWidth + Self.dotSpacing + segment.label.captionWidth
        }
    }

    private func content(fitted segments: [Segment]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart(segments) { segment in
                BarMark(
                    x: .value("Count", segment.count),
                    y: .value("Row", "status")
                )
                .foregroundStyle(segment.color)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 18)
            .clipShape(Capsule())

            HStack(spacing: Self.legendSpacing) {
                ForEach(segments) { segment in
                    HStack(spacing: Self.dotSpacing) {
                        Circle().fill(segment.color).frame(width: Self.dotWidth, height: Self.dotWidth)
                        Text(verbatim: segment.label)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
            }
        }
    }
}

#Preview("SegmentBar") {
    SegmentBar(
        segments: StatusBreakdown.sample(
            success: 8_140,
            redirect: 210,
            clientError: 96,
            serverError: 18
        ).segments
    )
    .padding(.horizontal)
}
