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

@Suite("DeviceModel")
struct DeviceModelTests {
    @Test(
        "Maps known hardware identifiers to marketing names",
        arguments: [
            ("iPhone16,1", "iPhone 15 Pro"),
            ("iPhone17,3", "iPhone 16"),
            ("iPhone18,4", "iPhone Air"),
            ("iPad14,1", "iPad mini (6th generation)"),
            ("iPad16,3", "iPad Pro (11-inch) (M4)"),
            ("iPod9,1", "iPod touch (7th generation)"),
            ("Watch7,5", "Apple Watch Ultra 2"),
            ("Watch7,17", "Apple Watch Series 11"),
        ])
    func mapsKnownIdentifiers(identifier: String, name: String) {
        #expect(DeviceModel(identifier: identifier).name == name)
    }

    @Test(
        "Falls back to the raw identifier for unknown or malformed values",
        arguments: [
            "iPhone99,9",
            "iphone 18.4",
            "arm64",
            "",
        ])
    func fallsBackToIdentifier(identifier: String) {
        #expect(DeviceModel(identifier: identifier).name == identifier)
    }

    @Test(
        "Picks a symbol per device family",
        arguments: [
            ("iPhone16,1", "iphone"),
            ("iPad14,1", "ipad"),
            ("Watch7,5", "applewatch"),
            ("iPod9,1", "iphone"),
        ])
    func picksSymbol(identifier: String, symbol: String) {
        #expect(DeviceModel(identifier: identifier).symbol == symbol)
    }
}
