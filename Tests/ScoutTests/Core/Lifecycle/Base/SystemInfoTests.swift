//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("SystemInfo")
struct SystemInfoTests {
    @Test("deviceModel resolves to a non-empty identifier")
    func deviceModel() {
        #expect(SystemInfo.deviceModel.count > 0)
    }

    @Test("osVersion pairs the platform name with a version number")
    func osVersion() {
        let value = SystemInfo.osVersion
        #expect(value.contains(" "))
        #expect(value.contains("."))
    }

    @Test("locale matches the current locale identifier")
    func locale() {
        #expect(SystemInfo.locale == Locale.current.identifier)
    }

    @Test("channel is one of the known distribution channels")
    func channel() {
        #expect(["Debug", "Simulator", "TestFlight", "App Store"].contains(SystemInfo.channel))
        #expect(SystemInfo.channel == SystemInfo.buildChannel.rawValue)
    }

    @Test("every channel but the App Store counts as an internal build")
    func internalBuild() {
        #expect(SystemInfo.isInternalBuild == (SystemInfo.buildChannel != .appStore))
    }
}
