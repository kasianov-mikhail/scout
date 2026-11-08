//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@Suite("DevicesExport")
struct DevicesExportTests {
    @Test("Models render their device, session, OS, and crash counts")
    func testDevicesExport() throws {
        let model = DeviceModelSummary(
            model: "iPhone16,1",
            devices: 12,
            sessions: 4_100,
            crashes: 3,
            osRange: DeviceOSRange(versions: ["iOS 17.3", "iOS 17.4"])
        )
        let text = try #require(DevicesExport(models: [model]).text)

        #expect(text.hasPrefix("# Scout Devices"))
        #expect(text.contains("1 model"))
        #expect(text.contains("12 devices"))
        #expect(text.contains("iPhone 15 Pro"))
        #expect(text.contains("4100 sessions"))
        #expect(text.contains("iOS 17.3–17.4"))
        #expect(text.contains("3 crashes"))
    }

    @Test("Rows follow the provider order")
    func testDevicesExportOrder() throws {
        let newest = DeviceModelSummary(
            model: "iPhone16,1",
            devices: 4,
            sessions: 400,
            crashes: 2,
            osRange: DeviceOSRange(versions: ["iOS 17.4"])
        )
        let older = DeviceModelSummary(
            model: "iPhone14,5",
            devices: 2,
            sessions: 200,
            crashes: 0,
            osRange: DeviceOSRange(versions: ["iOS 16.7"])
        )
        let text = try #require(DevicesExport(models: [newest, older]).text)

        let newestRange = try #require(text.range(of: "iPhone 15 Pro"))
        let olderRange = try #require(text.range(of: "iPhone 13"))
        #expect(newestRange.lowerBound < olderRange.lowerBound)
    }

    @Test("An empty roster exports nothing")
    func testEmptyDevicesExport() {
        #expect(DevicesExport(models: []).text == nil)
    }
}
