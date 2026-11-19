//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension AlertDraft {
    var valueText: String {
        switch watch {
        case .crashFreeDrop:
            Stability(stabilityThreshold).formatted
        case .eventCount:
            String(Int(countThreshold))
        case .eventSpike, .eventSilence:
            ""
        }
    }

    var thresholdTitle: String {
        if watch == .eventCount, countComparison == .below {
            "Alert below"
        } else {
            watch == .eventCount ? "Alert above" : "Alert below"
        }
    }

    var thresholdUnit: String {
        watch == .eventCount ? "an hour" : "crash-free"
    }

    var countIsBelow: Bool {
        countComparison == .below
    }

    var hint: String {
        switch watch {
        case .crashFreeDrop:
            "Alert after \(sensitivity.holdBuckets) \(hoursWord(sensitivity.holdBuckets)) below the line, so one bad hour does not wake you."
        case .eventSpike:
            "Alert when the event stays at this level for a full hour."
        case .eventSilence:
            "Alert when the event stays quiet for a full hour."
        case .eventCount:
            "Alert when the event stays \(countComparison == .below ? "below" : "above") this number for \(hoursWord(sensitivity.holdBuckets))."
        }
    }

    private func hoursWord(_ hours: Int) -> String {
        hours == 1 ? "hour" : "hours"
    }
}
