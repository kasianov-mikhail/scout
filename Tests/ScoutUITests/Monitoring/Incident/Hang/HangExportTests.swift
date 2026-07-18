//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI
@testable import Support

struct HangExportTests {
    private let base = Date(timeIntervalSince1970: 1_700_000_000)

    private func at(_ seconds: TimeInterval) -> Date {
        base.addingTimeInterval(seconds)
    }

    @Test("A single hang renders its date, duration, reason, and fenced stack trace")
    func testSingleHangExport() {
        let hang = Hang.stub(
            name: "Main Thread Blocked",
            reason: "found nil",
            stackTrace: ["0 A 0x1 f + 1", "1 B 0x2 g + 2"],
            duration: 4.2,
            date: at(0)
        )
        let text = HangExport(hang: hang).text

        #expect(text.hasPrefix("# Scout Hang — Main Thread Blocked"))
        #expect(text.contains(ExportFormat.timestamp(at(0))))
        #expect(text.contains("Duration: 4.2 s"))
        #expect(text.contains("Reason: found nil"))
        #expect(text.contains("## Stack Trace"))
        #expect(text.contains("0 A 0x1 f + 1"))
        #expect(text.contains("```"))
    }

    @Test("A bare hang exports just its title and duration")
    func testSingleHangExportOmitsEmptyParts() {
        let hang = Hang.stub(name: "E", reason: nil, stackTrace: [], duration: 3.5, date: nil)
        #expect(HangExport(hang: hang).text == "# Scout Hang — E\n\nDuration: 3.5 s")
    }

    @Test("A group renders its summary, top frame, and occurrence rows")
    func testGroupExport() {
        let device = UUID()
        let session = UUID()
        let hangs = [
            Hang.stub(
                name: "Image Layout Pass",
                fingerprint: "fp",
                reason: "blocked on layout",
                stackTrace: ["2 Scout 0xabc layout + 12"],
                duration: 4.2,
                deviceID: device,
                sessionID: session,
                date: at(0)
            ),
            Hang.stub(
                name: "Image Layout Pass",
                fingerprint: "fp",
                reason: "blocked on layout",
                stackTrace: ["2 Scout 0xdef layout + 99"],
                duration: 9.8,
                deviceID: device,
                sessionID: session,
                date: at(3600)
            ),
        ]
        let group = IncidentGroup.groups(from: hangs)[0]
        let text = HangGroupExport(group: group).text

        #expect(text.hasPrefix("# Scout Hang Issue — Image Layout Pass"))
        #expect(text.contains("2 occurrences · 1 device · 1 session"))
        #expect(text.contains("First seen") && text.contains("Last seen"))
        #expect(text.contains("Max duration: 9.8 s"))
        #expect(text.contains("Top frame: 2 Scout 0xdef layout + 99"))
        #expect(text.contains("## Occurrences"))
        #expect(
            text.contains(
                "- \(ExportFormat.timestamp(at(3600)))  9.8 s  (device \(ExportFormat.shortID(device)), session \(ExportFormat.shortID(session)))"
            )
        )
    }

    @Test("Occurrence rows follow the newest-first order")
    func testGroupExportOrdersOccurrences() throws {
        let hangs = [
            Hang.stub(name: "E", fingerprint: "fp", stackTrace: ["1 A 0x1 f + 1"], duration: 3.1, date: at(0)),
            Hang.stub(name: "E", fingerprint: "fp", stackTrace: ["1 A 0x2 f + 2"], duration: 3.2, date: at(7200)),
        ]
        let text = HangGroupExport(group: IncidentGroup.groups(from: hangs)[0]).text

        let newer = try #require(text.range(of: ExportFormat.timestamp(at(7200))))
        let older = try #require(text.range(of: ExportFormat.timestamp(at(0))))
        #expect(newer.lowerBound < older.lowerBound)
    }
}
