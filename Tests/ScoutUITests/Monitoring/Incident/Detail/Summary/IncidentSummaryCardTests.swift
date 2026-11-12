//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("IncidentSummaryCard")
struct IncidentSummaryCardTests {
    private let today = Date(timeIntervalSince1970: 1_700_006_400).startOfDay

    @Test("Occurrence bars split the last week by day")
    func occurrenceBars() {
        let records = [
            Crash.stub(date: today),
            Crash.stub(date: today),
            Crash.stub(date: today.addingDay(-6)),
            Crash.stub(date: today.addingDay(-7)),
        ]

        let card = IncidentSummaryCard.occurrences(records: records, value: "4", now: today)

        #expect(card.title == "OCCURRENCES")
        #expect(card.value == "4")
        #expect(card.bars.count == 7)
        #expect(card.bars.first == 1)
        #expect(card.bars.last == 2)
        #expect(card.change == "+200%")
    }

    @Test("A group without the previous week omits the change")
    func missingPrevious() {
        let records = [Crash.stub(date: today)]

        let card = IncidentSummaryCard.occurrences(records: records, value: "1", now: today)

        #expect(card.change == nil)
    }

    @Test("Device bars count distinct devices per day")
    func deviceBars() {
        let first = UUID()
        let second = UUID()
        let records = [
            Crash.stub(deviceID: first, date: today),
            Crash.stub(deviceID: first, date: today),
            Crash.stub(deviceID: second, date: today),
            Crash.stub(deviceID: second, date: today.addingDay(-7)),
        ]

        let card = IncidentSummaryCard.devices(records: records, value: "2", now: today)

        #expect(card.title == "DEVICES")
        #expect(card.bars.last == 2)
        #expect(card.change == "+100%")
    }

    @Test("The longest hang card shows the peak duration and its weekly change")
    func longestHang() {
        let records = [
            Hang.stub(duration: 9.8, date: today),
            Hang.stub(duration: 4.6, date: today.addingDay(-6)),
            Hang.stub(duration: 3, date: today.addingDay(-7)),
        ]

        let card = IncidentSummaryCard.longest(records: records, now: today)

        #expect(card.title == "LONGEST")
        #expect(card.value == "9.8 s")
        #expect(card.bars.last == 9.8)
        #expect(card.change == "+6.8 s")
    }

    @Test("The peak resource card reads the amount from the reason")
    func peakResource() {
        let records = [
            makeResource(reason: "84 s of CPU time in 180 s", at: today),
            makeResource(reason: "61 s of CPU time in 180 s", at: today.addingDay(-7)),
        ]

        let card = IncidentSummaryCard.peak(records: records, now: today)

        #expect(card.title == "PEAK CPU")
        #expect(card.value == "84 s")
        #expect(card.bars.last == 84)
        #expect(card.change == "+23 s")
    }

    @Test("A reason without an amount leaves the peak at zero")
    func peakWithoutAmount() {
        let records = [makeResource(reason: "CPU time exceeded", at: today)]

        let card = IncidentSummaryCard.peak(records: records, now: today)

        #expect(card.value == "0")
        #expect(card.change == nil)
        #expect(card.bars.allSatisfy { $0 == 0 })
    }
}

extension IncidentSummaryCardTests {
    private func makeResource(reason: String, at date: Date) -> ResourceException {
        ResourceException(
            name: "CPU Exception",
            fingerprint: "cpu",
            reason: reason,
            stackTrace: [],
            resourceKind: .cpu,
            date: date,
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: nil,
            launchID: nil,
            sessionID: nil
        )
    }
}
