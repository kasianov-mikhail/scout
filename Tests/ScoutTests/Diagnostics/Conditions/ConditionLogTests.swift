//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("ConditionLog")
struct ConditionLogTests {
    let date = Date(timeIntervalSince1970: 1_750_000_000)

    @Test("A session start records only the states that differ from the default")
    func startSkipsDefaults() {
        var log = ConditionLog()

        let started = [
            log.start(current: [.thermalNominal, .lowPowerOff]),
            log.start(current: [.thermalSerious, .lowPowerOff]),
        ]

        #expect(started == [[], [.thermalSerious]])
    }

    @Test("A state change is recorded once")
    func stateChangeOnce() {
        var log = ConditionLog()
        _ = log.start(current: [.thermalNominal, .lowPowerOff])

        let admitted = [
            log.admits(condition: .thermalNominal, date: date),
            log.admits(condition: .thermalFair, date: date),
            log.admits(condition: .thermalFair, date: date),
            log.admits(condition: .lowPowerOn, date: date),
            log.admits(condition: .thermalNominal, date: date),
        ]

        #expect(admitted == [false, true, false, true, true])
    }

    @Test("Memory pressure of one kind is recorded once a minute")
    func memoryThrottle() {
        var log = ConditionLog()

        let admitted = [
            log.admits(condition: .memoryWarning, date: date),
            log.admits(condition: .memoryWarning, date: date.addingTimeInterval(30)),
            log.admits(condition: .memoryCritical, date: date.addingTimeInterval(30)),
            log.admits(condition: .memoryWarning, date: date.addingTimeInterval(60)),
        ]

        #expect(admitted == [true, false, true, true])
    }
}
