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
            .scoutEventName
        case .screen, .crash, .hang, .resource:
            .system(size: 16, weight: .semibold)
        case .start, .end:
            .scoutCaptionStrong
        case .gap:
            .scoutCaption
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
            .scoutValue
        default:
            .scoutCaption
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

let sessionError = Color.fillDanger
let sessionLive = Color.fillSuccess
let sessionLiveInk = Color.textSuccess
let sessionLiveHalo = Color.tintSuccess
let sessionWarningTint = Color.tintCaution
let sessionCriticalTint = Color.tintDanger
