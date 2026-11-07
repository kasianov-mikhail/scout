//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension SessionTimelineRowView {
    var isGap: Bool {
        switch row.kind {
        case .gap:
            true
        default:
            false
        }
    }

    var titleFont: Font {
        switch row.kind {
        case .event:
            .system(size: 16, design: .monospaced)
        case .screen, .crash, .hang, .resource:
            .system(size: 16, weight: .semibold)
        case .start, .end:
            .system(size: 13, weight: .semibold)
        case .gap:
            .system(size: 13)
        }
    }

    var titleColor: Color {
        switch row.kind {
        case .start, .end(.background):
            Color.timelineSession
        case .end(.crash):
            Color.timelineCrashInk
        case .end(.live):
            sessionLiveInk
        case .end(.unknown):
            Color.timelineMuted
        case .crash, .hang, .resource:
            row.incident?.timelineInk ?? .primary
        case .gap:
            Color.timelineMuted
        case .event, .screen:
            .primary
        }
    }

    var subtitleFont: Font {
        switch row.kind {
        case .crash, .hang, .resource:
            .system(size: 13, design: .monospaced)
        default:
            .system(size: 13)
        }
    }

    var tint: Color? {
        switch row.kind {
        case .event:
            switch row.level {
            case .warning, .error:
                sessionWarningTint
            case .critical:
                sessionCriticalTint
            default:
                nil
            }
        case .crash:
            Color.timelineCrash.opacity(0.10)
        default:
            nil
        }
    }
}

extension EventLevel {
    var sessionLabel: String {
        description.uppercased()
    }

    var sessionColor: Color {
        switch self {
        case .warning:
            Color.timelineHang
        case .error:
            sessionError
        case .critical:
            Color.timelineCrashInk
        default:
            .clear
        }
    }

    var sessionChipInk: Color {
        switch self {
        case .warning:
            Color.timelineHangInk
        case .error:
            Color.timelineCrashInk
        case .critical:
            .white
        default:
            .clear
        }
    }

    var sessionChipBackground: Color {
        switch self {
        case .warning:
            Color.timelineHang.opacity(0.14)
        case .error:
            sessionError.opacity(0.12)
        case .critical:
            Color.timelineCrashInk
        default:
            .clear
        }
    }
}

let sessionError = Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255)
let sessionLive = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255)
let sessionLiveInk = Color(red: 30 / 255, green: 125 / 255, blue: 52 / 255)
let sessionLiveHalo = Color(red: 227 / 255, green: 246 / 255, blue: 232 / 255)
let sessionWarningTint = Color(red: 255 / 255, green: 204 / 255, blue: 0 / 255).opacity(0.12)
let sessionCriticalTint = sessionError.opacity(0.10)
