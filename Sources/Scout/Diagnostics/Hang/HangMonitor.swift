//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HangMonitor {
    static let pingInterval: TimeInterval = 1

    // In the spirit of MetricKit's hang buckets: a first report once the main
    // thread has been unresponsive for 3s, and a more severe one at 8s — around
    // where the system watchdog would otherwise kill the app.
    static let warningThreshold: TimeInterval = 3
    static let criticalThreshold: TimeInterval = 8

    // A check arriving this late means the watchdog queue itself stopped running:
    // the process was suspended in the background or the device slept. The gap
    // then measures the freeze, not an unresponsive main thread.
    static let stallThreshold = pingInterval * 1.5

    private var pingDate: TimeInterval
    private var checkDate: TimeInterval
    private var reportedWarning = false
    private var reportedCritical = false

    init(now: TimeInterval) {
        pingDate = now
        checkDate = now
    }

    mutating func ping(at now: TimeInterval) {
        pingDate = now
        reportedWarning = false
        reportedCritical = false
    }

    mutating func check(at now: TimeInterval) -> TimeInterval? {
        let stall = now - checkDate
        checkDate = now

        guard stall <= Self.stallThreshold else {
            ping(at: now)
            return nil
        }

        let elapsed = now - pingDate

        if elapsed >= Self.criticalThreshold, !reportedCritical {
            reportedCritical = true
            return elapsed
        } else if elapsed >= Self.warningThreshold, !reportedWarning {
            reportedWarning = true
            return elapsed
        }

        return nil
    }
}
