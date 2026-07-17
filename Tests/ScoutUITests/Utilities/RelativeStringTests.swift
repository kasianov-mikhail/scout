//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

struct RelativeStringTests {
    @Test("Old date shows relative string")
    func oldDate() {
        let date = Date(timeIntervalSinceNow: -3600)
        #expect(date.relativeString != "recently")
    }

    @Test("Recent date shows 'recently'")
    func recentDate() {
        let date = Date(timeIntervalSinceNow: -30)
        #expect(date.relativeString == "recently")
    }

    @Test("Future date shows 'recently'")
    func futureDate() {
        let date = Date(timeIntervalSinceNow: 100)
        #expect(date.relativeString == "recently")
    }

    @Test("Boundary at exactly 60 seconds")
    func boundary() {
        let date = Date(timeIntervalSinceNow: -59)
        #expect(date.relativeString == "recently")
    }
}
