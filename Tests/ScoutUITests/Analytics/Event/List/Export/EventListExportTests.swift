//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

@Suite("EventListExport")
struct EventListExportTests {
    private let base = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("Events render their timestamp, name, and level")
    func testEventListExport() throws {
        let events = [
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
        let text = try #require(EventListExport(events: events).text)

        #expect(text.hasPrefix("# Scout Events"))
        #expect(text.contains("2 events"))
        #expect(text.contains("- \(ExportFormat.timestamp(base))  app_launch  [info]"))
        #expect(text.contains("- button_tap"))
    }

    @Test("An empty list exports nothing")
    func testEmptyEventListExport() {
        #expect(EventListExport(events: []).text == nil)
    }
}
