//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension AlertDraft.Watch {
    var title: String {
        switch self {
        case .crashFreeDrop:
            "Crash-free drops"
        case .eventSpike:
            "Event spikes"
        case .eventSilence:
            "Event goes quiet"
        case .eventCount:
            "Event passes a number"
        }
    }

    var templateTitle: String {
        switch self {
        case .crashFreeDrop:
            "Crash-free sessions drop"
        case .eventSpike:
            "An event spikes"
        case .eventSilence:
            "An event goes quiet"
        case .eventCount:
            "An event passes a number"
        }
    }

    var detail: String {
        switch self {
        case .crashFreeDrop:
            "Fewer sessions end without a crash"
        case .eventSpike:
            "An event happens much more often than usual"
        case .eventSilence:
            "An event stops arriving"
        case .eventCount:
            "An event count goes over a limit you set"
        }
    }

    var templateDetail: String {
        switch self {
        case .crashFreeDrop:
            "Alert when fewer than 99.5% of sessions end without a crash."
        case .eventSpike:
            "Alert when an event happens much more often than usual, like PaymentDeclined at night."
        case .eventSilence:
            "Alert when an event happens much less than usual, like CheckoutCompleted stopping."
        case .eventCount:
            "Alert when an event happens more than a set number of times an hour."
        }
    }

    var summary: String {
        switch self {
        case .crashFreeDrop:
            "Fewer sessions end without a crash"
        case .eventSpike:
            "It happens much more often than usual"
        case .eventSilence:
            "It stops arriving"
        case .eventCount:
            "The count goes over a limit you set"
        }
    }

    var isEvent: Bool {
        self != .crashFreeDrop
    }

    var hasThreshold: Bool {
        self == .crashFreeDrop || self == .eventCount
    }

    func detail(for sensitivity: AlertDraft.Sensitivity, isBelow: Bool = false) -> String {
        switch self {
        case .crashFreeDrop:
            "\(sensitivity.holdBuckets) h below"
        case .eventCount:
            "\(sensitivity.holdBuckets) h \(isBelow ? "below" : "above")"
        case .eventSpike:
            String(format: "%g× usual", sensitivity.spikeFactor)
        case .eventSilence:
            String(format: "%g× usual", sensitivity.silenceFactor)
        }
    }
}
