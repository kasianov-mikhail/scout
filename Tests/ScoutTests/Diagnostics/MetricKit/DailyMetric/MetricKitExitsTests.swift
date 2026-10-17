//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("MetricKitExits")
struct MetricKitExitsTests {
    @Test("Foreground and background counts add up per reason")
    func countsAddUp() {
        let exits = MetricKitExits(
            foreground: [.normal: 12, .watchdog: 1],
            background: [.normal: 30, .watchdog: 2, .memoryPressure: 5]
        )

        #expect(exits.counts == [.normal: 42, .watchdog: 3, .memoryPressure: 5])
    }

    @Test("Reasons without exits are left out")
    func zeroCountsAreDropped() {
        let exits = MetricKitExits(foreground: [.normal: 4, .badAccess: 0], background: [.cpuLimit: 0])

        #expect(exits.counts == [.normal: 4])
    }

    @Test("Each reason becomes one exit reading")
    func readingsPerReason() {
        let exits = MetricKitExits(counts: [.watchdog: 2, .normal: 9])

        #expect(
            exits.readings == [
                DailyMetricReading(name: "exit", category: "normal", value: 9),
                DailyMetricReading(name: "exit", category: "watchdog", value: 2),
            ]
        )
    }
}
