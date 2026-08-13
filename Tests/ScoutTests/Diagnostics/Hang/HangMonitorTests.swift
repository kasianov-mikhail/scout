//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("HangMonitor")
struct HangMonitorTests {
    @Test("Reports once the main thread stops pinging")
    func reportsWarning() {
        var monitor = HangMonitor(now: 0)

        #expect(monitor.check(at: 1) == nil)
        #expect(monitor.check(at: 2) == nil)
        #expect(monitor.check(at: 3) == 3)
    }

    @Test("Escalates once the hang reaches the critical threshold")
    func escalatesToCritical() {
        var monitor = HangMonitor(now: 0)

        let durations = (1...9).compactMap { monitor.check(at: TimeInterval($0)) }

        #expect(durations == [3, 8])
    }

    @Test("A ping ends the hang and re-arms both reports")
    func pingRearmsReports() {
        var monitor = HangMonitor(now: 0)

        #expect(monitor.check(at: 1) == nil)
        #expect(monitor.check(at: 2) == nil)
        #expect(monitor.check(at: 3) == 3)

        monitor.ping(at: 3.5)

        #expect(monitor.check(at: 4) == nil)
        #expect(monitor.check(at: 5) == nil)
        #expect(monitor.check(at: 6.5) == 3)
    }

    @Test("Treats a frozen watchdog as a suspended process, not a hang")
    func suspensionIsNotAHang() {
        var monitor = HangMonitor(now: 0)

        #expect(monitor.check(at: 1) == nil)
        #expect(monitor.check(at: 301) == nil)
        #expect(monitor.check(at: 302) == nil)
    }

    @Test("Reports a hang that starts after resuming")
    func reportsAfterResuming() {
        var monitor = HangMonitor(now: 0)

        #expect(monitor.check(at: 301) == nil)
        #expect(monitor.check(at: 302) == nil)
        #expect(monitor.check(at: 303) == nil)
        #expect(monitor.check(at: 304) == 3)
    }
}
