//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SkeletonRowView: View {
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

    var height: CGFloat {
        switch row.track {
        case .milestone, .event:
            .rowRegular
        case .fork, .merge, .gap:
            .rowStep
        }
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
}
