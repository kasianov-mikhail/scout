//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("MetricKitExits")
struct MetricKitExitsTests {
    private let window = DateInterval(start: Date(timeIntervalSince1970: 1_750_000_000), duration: 86_400)
    private let installID = UUID()

    @Test("Foreground and background counts add up per reason")
    func countsAddUp() {
        let exits = MetricKitExits(
            foreground: [.normal: 12, .watchdog: 1],
            background: [.normal: 30, .watchdog: 2, .memoryPressure: 5],
            appVersion: "3.2.0",
            window: window
        )

        #expect(exits.counts == [.normal: 42, .watchdog: 3, .memoryPressure: 5])
    }

    @Test("Reasons without exits are left out")
    func zeroCountsAreDropped() {
        let exits = MetricKitExits(foreground: [.normal: 4, .badAccess: 0], background: [.cpuLimit: 0], appVersion: nil, window: window)

        #expect(exits.counts == [.normal: 4])
    }

    @Test("The same report gives the same id for a reason")
    func idIsDeterministic() {
        let first = makeExits().id(of: .watchdog, installID: installID)
        let second = makeExits().id(of: .watchdog, installID: installID)

        #expect(first == second)
    }

    @Test("The id differs by reason, install, version, and window")
    func idSeparatesReports() {
        let exits = makeExits()
        let base = exits.id(of: .watchdog, installID: installID)

        let later = DateInterval(start: window.end, duration: 86_400)
        let others = [
            exits.id(of: .normal, installID: installID),
            exits.id(of: .watchdog, installID: UUID()),
            makeExits(appVersion: "3.2.1").id(of: .watchdog, installID: installID),
            makeExits(window: later).id(of: .watchdog, installID: installID),
        ]

        #expect(Set(others + [base]).count == 5)
    }

    private func makeExits(appVersion: String = "3.2.0", window: DateInterval? = nil) -> MetricKitExits {
        MetricKitExits(counts: [.watchdog: 1, .normal: 9], appVersion: appVersion, window: window ?? self.window)
    }
}
