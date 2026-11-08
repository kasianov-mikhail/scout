//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

@Suite("DeviceOSRange")
struct DeviceOSRangeTests {
    @Test("A single version keeps its full and short name")
    func singleVersion() {
        let range = DeviceOSRange(versions: ["iOS 17.4"])

        #expect(range.label == "iOS 17.4")
        #expect(range.shortLabel == "17.4")
    }

    @Test("Versions with the same system collapse the prefix")
    func sameSystemRange() {
        let range = DeviceOSRange(versions: ["iOS 17.4", "iOS 17.3"])

        #expect(range.label == "iOS 17.3–17.4")
        #expect(range.shortLabel == "17.3–17.4")
    }

    @Test("Versions are ordered numerically, not lexically")
    func numericOrder() {
        let range = DeviceOSRange(versions: ["iOS 17.10", "iOS 17.9"])

        #expect(range.label == "iOS 17.9–17.10")
    }

    @Test("Different systems keep their full names")
    func mixedSystems() {
        let range = DeviceOSRange(versions: ["iPadOS 17.2", "iOS 16.7"])

        #expect(range.label == "iOS 16.7–iPadOS 17.2")
        #expect(range.shortLabel == "iOS 16.7–iPadOS 17.2")
    }

    @Test("No versions yields no label")
    func emptyRange() {
        let range = DeviceOSRange(versions: [])

        #expect(range.label == nil)
        #expect(range.shortLabel == nil)
    }

    @Test("Duplicate and empty versions are dropped")
    func duplicateVersions() {
        let range = DeviceOSRange(versions: ["iOS 17.4", "iOS 17.4", ""])

        #expect(range.versions == ["iOS 17.4"])
    }
}
