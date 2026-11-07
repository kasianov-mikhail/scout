//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionSkeletonChip: Identifiable {
    let id: Int
    let width: CGFloat
}

extension SessionSkeletonChip {
    static let samples = [
        SessionSkeletonChip(id: 0, width: 96),
        SessionSkeletonChip(id: 1, width: 56),
        SessionSkeletonChip(id: 2, width: 40),
        SessionSkeletonChip(id: 3, width: 74),
        SessionSkeletonChip(id: 4, width: 64),
    ]
}

struct SessionSkeletonRow {
    enum Kind {
        case start
        case screen
        case event
    }

    let kind: Kind
    let width: CGFloat
    let extraWidth: CGFloat?
    var endsAtCenter = false

    var height: CGFloat {
        switch kind {
        case .start:
            36
        case .screen:
            52
        case .event:
            44
        }
    }

    var titleHeight: CGFloat {
        switch kind {
        case .start:
            9
        case .screen:
            11
        case .event:
            9
        }
    }
}

extension SessionSkeletonRow {
    static let samples = [
        SessionSkeletonRow(kind: .start, width: 120, extraWidth: nil),
        SessionSkeletonRow(kind: .screen, width: 99, extraWidth: 46),
        SessionSkeletonRow(kind: .event, width: 136, extraWidth: nil),
        SessionSkeletonRow(kind: .event, width: 64, extraWidth: nil),
        SessionSkeletonRow(kind: .screen, width: 72, extraWidth: 46),
        SessionSkeletonRow(kind: .event, width: 136, extraWidth: nil),
        SessionSkeletonRow(kind: .event, width: 64, extraWidth: nil),
        SessionSkeletonRow(kind: .screen, width: 126, extraWidth: 46),
        SessionSkeletonRow(kind: .event, width: 136, extraWidth: nil),
        SessionSkeletonRow(kind: .event, width: 64, extraWidth: nil),
        SessionSkeletonRow(kind: .screen, width: 54, extraWidth: 46),
        SessionSkeletonRow(kind: .event, width: 136, extraWidth: nil),
        SessionSkeletonRow(kind: .event, width: 64, extraWidth: nil),
        SessionSkeletonRow(kind: .screen, width: 99, extraWidth: 46),
        SessionSkeletonRow(kind: .event, width: 136, extraWidth: nil, endsAtCenter: true),
    ]
}

struct SessionSkeletonRowView: View {
    let row: SessionSkeletonRow
    let delay: Double

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 24, y: row.kind == .start ? size.height / 2 : 0))
                path.addLine(to: CGPoint(x: 24, y: row.endsAtCenter ? size.height / 2 : size.height))

                context.stroke(path, with: .color(Color.timelineTrack), style: StrokeStyle(lineWidth: 2))
            }

            marker

            HStack(spacing: 8) {
                SkeletonBar(width: row.width, height: row.titleHeight, delay: delay)

                if let extraWidth = row.extraWidth {
                    SkeletonBar(width: extraWidth, height: 9, delay: delay)
                }

                Spacer(minLength: 8)

                SkeletonBar(width: 36, height: 9, delay: delay)
            }
            .padding(.leading, 56)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: row.height)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var marker: some View {
        switch row.kind {
        case .start:
            Circle()
                .fill(Color.timelineTrack)
                .frame(width: 6, height: 6)
                .offset(x: 21, y: row.height / 2 - 3)
        case .screen:
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.timelineBackground)
                    .frame(width: 26, height: 26)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.timelineTrack)
                    .frame(width: 20, height: 20)
            }
            .offset(x: 11, y: row.height / 2 - 13)
        case .event:
            Circle()
                .strokeBorder(Color.timelineTrack, lineWidth: 2)
                .background(Circle().fill(Color.timelineBackground))
                .frame(width: 12, height: 12)
                .offset(x: 18, y: row.height / 2 - 6)
        }
    }
}
