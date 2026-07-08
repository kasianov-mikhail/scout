//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("DevicesExport")
struct DevicesExportTests {
    @Test("Devices render their model, OS, and counts")
    func testDevicesExport() throws {
        let device = DeviceSummary(id: UUID(), model: "iPhone15,3", osVersion: "iOS 17.4", lastSeen: Date(timeIntervalSince1970: 1_700_000_000), sessions: 10, crashes: 2)
        let text = try #require(DevicesExport(devices: [device]).text)

        #expect(text.hasPrefix("# Scout Devices"))
        #expect(text.contains("1 device"))
        #expect(text.contains("iPhone15,3"))
        #expect(text.contains("iOS 17.4"))
        #expect(text.contains("10 sessions"))
        #expect(text.contains("2 crashes"))
        #expect(text.contains(ExportFormat.timestamp(Date(timeIntervalSince1970: 1_700_000_000))))
    }

    @Test("Rows follow the newest-lastSeen-first order")
    func testDevicesExportOrdersByLastSeen() throws {
        let older = DeviceSummary(id: UUID(), model: "iPhone14,2", osVersion: "iOS 16.7", lastSeen: Date(timeIntervalSince1970: 0), sessions: 1, crashes: 0)
        let newer = DeviceSummary(id: UUID(), model: "iPhone15,3", osVersion: "iOS 17.4", lastSeen: Date(timeIntervalSince1970: 3600), sessions: 1, crashes: 0)
        let text = try #require(DevicesExport(devices: [older, newer]).text)

        let newerRange = try #require(text.range(of: "iPhone15,3"))
        let olderRange = try #require(text.range(of: "iPhone14,2"))
        #expect(newerRange.lowerBound < olderRange.lowerBound)
    }

    @Test("An empty roster exports nothing")
    func testEmptyDevicesExport() {
        #expect(DevicesExport(devices: []).text == nil)
    }
}
