//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CrashExportTests {
    private let base = Date(timeIntervalSince1970: 1_700_000_000)

    private func at(_ seconds: TimeInterval) -> Date {
        base.addingTimeInterval(seconds)
    }

    @Test("A single crash renders its date, reason, and fenced stack trace")
    func testSingleCrashExport() {
        let crash = Crash.stub(
            name: "SIGABRT",
            reason: "found nil",
            stackTrace: ["0 A 0x1 f + 1", "1 B 0x2 g + 2"],
            date: at(0)
        )
        let text = CrashExport(crash: crash).text

        #expect(text.hasPrefix("# Scout Crash — SIGABRT"))
        #expect(text.contains(ExportFormat.timestamp(at(0))))
        #expect(text.contains("Reason: found nil"))
        #expect(text.contains("## Stack Trace"))
        #expect(text.contains("0 A 0x1 f + 1"))
        #expect(text.contains("```"))
    }

    @Test("A bare crash exports just its title")
    func testSingleCrashExportOmitsEmptyParts() {
        let crash = Crash.stub(name: "E", reason: nil, stackTrace: [], date: nil)
        #expect(CrashExport(crash: crash).text == "# Scout Crash — E")
    }

    @Test("A group renders its summary, top frame, and occurrence rows")
    func testGroupExport() {
        let session = UUID()
        let crashes = [
            Crash.stub(
                name: "NSRangeException",
                fingerprint: "fp",
                reason: "index beyond bounds",
                stackTrace: ["2 Scout 0xabc objectAtIndex + 12"],
                sessionID: session,
                date: at(0)
            ),
            Crash.stub(
                name: "NSRangeException",
                fingerprint: "fp",
                reason: "index beyond bounds",
                stackTrace: ["2 Scout 0xdef objectAtIndex + 99"],
                sessionID: session,
                date: at(3600)
            ),
        ]
        let group = CrashGroup.groups(from: crashes)[0]
        let text = CrashGroupExport(group: group).text

        #expect(text.hasPrefix("# Scout Crash Issue — NSRangeException"))
        #expect(text.contains("2 occurrences · 1 session"))
        #expect(text.contains("First seen") && text.contains("Last seen"))
        #expect(text.contains("Reason: index beyond bounds"))
        #expect(text.contains("Top frame: 2 Scout 0xdef objectAtIndex + 99"))
        #expect(text.contains("## Occurrences"))
        #expect(
            text.contains(
                "- \(ExportFormat.timestamp(at(3600)))  (session \(ExportFormat.shortID(session)))"
            )
        )
    }

    @Test("Occurrence rows follow the newest-first order")
    func testGroupExportOrdersOccurrences() throws {
        let crashes = [
            Crash.stub(name: "E", fingerprint: "fp", stackTrace: ["1 A 0x1 f + 1"], date: at(0)),
            Crash.stub(name: "E", fingerprint: "fp", stackTrace: ["1 A 0x2 f + 2"], date: at(7200)),
        ]
        let text = CrashGroupExport(group: CrashGroup.groups(from: crashes)[0]).text

        let newer = try #require(text.range(of: ExportFormat.timestamp(at(7200))))
        let older = try #require(text.range(of: ExportFormat.timestamp(at(0))))
        #expect(newer.lowerBound < older.lowerBound)
    }
}
