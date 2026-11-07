//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelinePlaceholder: View {
    private let rows = SkeletonRow.samples

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: 8)

                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    SkeletonRowView(
                        row: row,
                        delay: Double(index) * 0.08,
                        showsSeparator: showsSeparator(after: index)
                    )
                }
            }
        }
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func showsSeparator(after index: Int) -> Bool {
        guard rows[index].track == .event, let next = rows[safe: index + 1] else {
            return false
        }
        return next.track == .event
    }
}

private struct SkeletonRow {
    enum Track {
        case milestone
        case event
        case fork
        case merge
        case gap
    }

    let track: Track
    let width: CGFloat
    let extraWidth: CGFloat?
}

extension SkeletonRow {
    static let samples: [SkeletonRow] = {
        var rows: [SkeletonRow] = [
            SkeletonRow(track: .milestone, width: 120, extraWidth: 74),
            SkeletonRow(track: .fork, width: 46, extraWidth: nil),
        ]

        let first = [106, 77, 134, 58, 106, 77, 134, 58, 106, 77]
        rows += first.map { SkeletonRow(track: .event, width: CGFloat($0), extraWidth: nil) }
        rows += [
            SkeletonRow(track: .merge, width: 74, extraWidth: nil),
            SkeletonRow(track: .gap, width: 28, extraWidth: nil),
            SkeletonRow(track: .milestone, width: 120, extraWidth: 74),
            SkeletonRow(track: .fork, width: 46, extraWidth: nil),
        ]

        let second = [106, 77, 134, 58, 106, 77, 134, 58, 106, 77, 134, 58, 106]
        rows += second.map { SkeletonRow(track: .event, width: CGFloat($0), extraWidth: nil) }
        return rows
    }()
}

private struct SkeletonRowView: View {
    let row: SkeletonRow
    let delay: Double
    let showsSeparator: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            rails

            marker

            bars
        }
        .frame(height: height)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(Color.timelineTrack)
                    .frame(height: 1)
                    .padding(.leading, 72)
                    .padding(.trailing, 16)
            }
        }
        .accessibilityHidden(true)
    }

    private var height: CGFloat {
        switch row.track {
        case .milestone, .event:
            44
        case .fork, .merge, .gap:
            36
        }
    }

    private var rails: some View {
        Canvas { context, size in
            switch row.track {
            case .milestone, .event:
                stroke(x: 24, height: size.height, dashed: false, context: &context)
            case .fork:
                stroke(x: 24, height: size.height, dashed: false, context: &context)
                fork(context: &context)
            case .merge:
                stroke(x: 24, height: size.height, dashed: false, context: &context)
                stroke(x: 48, height: size.height, dashed: false, context: &context)
                merge(context: &context)
            case .gap:
                stroke(x: 24, height: size.height, dashed: true, context: &context)
            }

            if row.track == .event {
                stroke(x: 48, height: size.height, dashed: false, context: &context)
            }
        }
        .frame(height: height)
    }

    @ViewBuilder
    private var marker: some View {
        switch row.track {
        case .milestone:
            ZStack {
                Circle()
                    .fill(Color.timelineBackground)
                    .frame(width: 26, height: 26)

                SkeletonBar(width: 20, height: 20, delay: delay, cornerRadius: 10, fill: Color.timelineTrack)
            }
            .offset(x: 11, y: height / 2 - 13)
        case .event:
            ZStack {
                SkeletonBar(width: 12, height: 12, delay: delay, cornerRadius: 6, fill: Color.timelineTrack)

                Circle()
                    .fill(Color.timelineBackground)
                    .frame(width: 8, height: 8)
            }
            .offset(x: 42, y: height / 2 - 6)
        case .fork, .merge, .gap:
            EmptyView()
        }
    }

    private var bars: some View {
        HStack(spacing: 8) {
            SkeletonBar(
                width: row.width,
                height: row.track == .event ? 12 : row.track == .milestone ? 11 : 9,
                delay: delay,
                fill: Color.timelineTrack
            )

            if let extraWidth = row.extraWidth {
                SkeletonBar(width: extraWidth, height: 9, delay: delay, fill: Color.timelineTrack)
            }

            Spacer(minLength: 8)

            if !row.track.isCompact {
                SkeletonBar(
                    width: row.track == .event ? 58 : 36,
                    height: 9,
                    delay: delay,
                    fill: Color.timelineTrack
                )
            }
        }
        .padding(.leading, 72)
        .padding(.trailing, 16)
        .frame(height: height)
    }

    private func stroke(x: CGFloat, height: CGFloat, dashed: Bool, context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: height))

        context.stroke(
            path,
            with: .color(Color.timelineTrack),
            style: StrokeStyle(lineWidth: 2, dash: dashed ? [4, 4] : [])
        )
    }

    private func fork(context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: 24, y: 6))
        path.addCurve(to: CGPoint(x: 48, y: 36), control1: CGPoint(x: 24, y: 26), control2: CGPoint(x: 48, y: 14))
        context.stroke(path, with: .color(Color.timelineTrack), style: StrokeStyle(lineWidth: 2))
    }

    private func merge(context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: 48, y: 0))
        path.addCurve(to: CGPoint(x: 24, y: 30), control1: CGPoint(x: 48, y: 22), control2: CGPoint(x: 24, y: 10))
        context.stroke(path, with: .color(Color.timelineTrack), style: StrokeStyle(lineWidth: 2))
    }
}

extension SkeletonRow.Track {
    fileprivate var isCompact: Bool {
        switch self {
        case .merge, .gap:
            true
        default:
            false
        }
    }
}

#Preview {
    NavigationStack {
        TimelinePlaceholder()
    }
}
