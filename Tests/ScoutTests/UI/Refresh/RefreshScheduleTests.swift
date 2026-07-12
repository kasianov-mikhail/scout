//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RefreshScheduleTests {
    @Test("Starts at the base interval")
    func baseInterval() {
        let schedule = RefreshSchedule()
        #expect(schedule.delay == .seconds(3))
    }

    @Test("Backs off along the Fibonacci sequence on consecutive failures")
    func fibonacciBackoff() {
        var schedule = RefreshSchedule()
        let expected: [Duration] = [
            .seconds(5), .seconds(8), .seconds(13), .seconds(21), .seconds(34), .seconds(55), .seconds(89),
        ]

        var produced: [Duration] = []
        for _ in expected {
            schedule.recordFailure()
            produced.append(schedule.delay)
        }

        #expect(produced == expected)
    }

    @Test("Resets to the base interval after a success")
    func resetOnSuccess() {
        var schedule = RefreshSchedule()
        schedule.recordFailure()
        schedule.recordFailure()
        #expect(schedule.delay == .seconds(8))

        schedule.recordSuccess()
        #expect(schedule.delay == .seconds(3))
    }

    @Test("Caps the delay at the maximum")
    func capsAtMax() {
        var schedule = RefreshSchedule()
        for _ in 0..<20 {
            schedule.recordFailure()
        }
        #expect(schedule.delay == .seconds(89))
    }
}
