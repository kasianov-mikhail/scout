//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("EventListExport")
struct EventListExportTests {
    private let base = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("Events render their timestamp, name, and level")
    func testEventListExport() throws {
        let text = try #require(EventListExport(events: makeEvents()).text)

        #expect(text.hasPrefix("# Scout Events"))
        #expect(text.contains("2 events"))
        #expect(text.contains("- \(ExportFormat.timestamp(base))  app_launch  [info]"))
        #expect(text.contains("- button_tap"))
    }

    @Test("An empty list exports nothing")
    func testEmptyEventListExport() {
        #expect(EventListExport(events: []).text == nil)
    }

    @Test("A truncated export states it is partial")
    func testTruncatedEventListExport() throws {
        let text = try #require(EventListExport(events: makeEvents(), isTruncated: true).text)

        #expect(text.contains("2 events loaded · more available"))
    }

    @Test("A complete export does not state it is partial")
    func testCompleteEventListExport() throws {
        let text = try #require(EventListExport(events: makeEvents()).text)

        #expect(text.contains("2 events"))
        #expect(!text.contains("more available"))
    }

    private func makeEvents() -> [Event] {
        [
            Event(
                name: "app_launch",
                level: .info,
                date: base,
                paramCount: nil,
                uuid: nil,
                id: "1",
                installID: nil,
                sessionID: nil,
                deviceID: nil
            ),
            Event(
                name: "button_tap",
                level: nil,
                date: nil,
                paramCount: nil,
                uuid: nil,
                id: "2",
                installID: nil,
                sessionID: nil,
                deviceID: nil
            ),
        ]
    }
}
