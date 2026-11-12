//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension SessionTimelineRowView {
    var railTop: CGFloat {
        switch row.kind {
        case .start:
            row.height / 2
        default:
            0
        }
    }

    var railBottom: CGFloat {
        switch row.kind {
        case .end:
            row.height / 2
        default:
            row.height
        }
    }

    var railColor: Color {
        switch row.kind {
        case .gap:
            Color.timelinePending
        case .end(.unknown):
            Color.timelineUnknown
        case .end(.crash):
            Color.timelineCrash
        default:
            Color.timelineSession
        }
    }

    var railDashed: Bool {
        switch row.kind {
        case .gap, .end(.unknown):
            true
        default:
            false
        }
    }

    @ViewBuilder
    var marker: some View {
        switch row.kind {
        case .start:
            circle(6, color: .timelineSession)
                .offset(x: 21, y: row.height / 2 - 3)
        case .event:
            if let level = row.level {
                haloCircle(10, color: level.sessionColor)
                    .offset(x: 16, y: row.height / 2 - 8)
            } else {
                ringCircle(12, color: .timelineSession)
                    .offset(x: 18, y: row.height / 2 - 6)
            }
        case .screen:
            screenMarker
                .offset(x: 11, y: row.height / 2 - 13)
        case .crash, .hang, .resource:
            incidentMarker
                .offset(x: 14, y: row.height / 2 - 10)
        case .gap:
            EmptyView()
        case .end(.live):
            ZStack {
                Circle().fill(sessionLiveHalo).frame(width: 20, height: 20)
                Circle().fill(sessionLive).frame(width: 12, height: 12)
            }
            .offset(x: 14, y: row.height / 2 - 10)
        case .end(.unknown):
            ringCircle(12, color: .timelineUnknown)
                .offset(x: 18, y: row.height / 2 - 6)
        case .end(.background):
            circle(6, color: .timelineSession)
                .offset(x: 21, y: row.height / 2 - 3)
        case .end(.crash):
            circle(6, color: .timelineCrash)
                .offset(x: 21, y: row.height / 2 - 3)
        }
    }

    fileprivate var screenMarker: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .radiusBadge)
                .fill(Color.timelineBackground)
                .frame(width: 26, height: 26)
            RoundedRectangle(cornerRadius: .radiusBadge)
                .fill(Color.timelineSession)
                .frame(width: 20, height: 20)
            Image(systemName: "iphone")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.textOnFill)
        }
    }

    fileprivate var incidentMarker: some View {
        ZStack {
            Circle()
                .fill(Color.timelineBackground)
                .frame(width: 20, height: 20)
            Circle()
                .strokeBorder(incidentColor, lineWidth: 2)
            Image(systemName: row.incident?.timelineSymbol ?? "exclamationmark")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(incidentColor)
        }
        .frame(width: 20, height: 20)
    }

    fileprivate var incidentColor: Color {
        row.incident?.timelineColor ?? .clear
    }

    fileprivate func circle(_ size: CGFloat, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }

    fileprivate func haloCircle(_ size: CGFloat, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(Color.timelineBackground)
                .frame(width: size + 6, height: size + 6)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
    }

    fileprivate func ringCircle(_ size: CGFloat, color: Color) -> some View {
        Circle()
            .strokeBorder(color, lineWidth: 2)
            .background(Circle().fill(Color.timelineBackground))
            .frame(width: size, height: size)
    }

    func chip(_ text: String, level: EventLevel) -> some View {
        Text(verbatim: text)
            .font(.scoutBadge)
            .tracking(0.3)
            .foregroundStyle(level.sessionChipInk)
            .badgeStyle(fill: level.sessionChipBackground)
            .fixedSize()
    }
}
