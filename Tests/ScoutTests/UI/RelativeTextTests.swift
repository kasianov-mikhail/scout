//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Testing

@testable import Scout

struct RelativeTextTests {
    @Test("Old date shows relative string")
    func oldDate() {
        let date = Date(timeIntervalSinceNow: -3600)
        let text = date.relativeText
        #expect(text != Text("recently"))
    }

    @Test("Recent date shows 'recently'")
    func recentDate() {
        let date = Date(timeIntervalSinceNow: -30)
        let text = date.relativeText
        #expect(text == Text("recently"))
    }

    @Test("Future date shows 'recently'")
    func futureDate() {
        let date = Date(timeIntervalSinceNow: 100)
        let text = date.relativeText
        #expect(text == Text("recently"))
    }

    @Test("Boundary at exactly 60 seconds")
    func boundary() {
        let date = Date(timeIntervalSinceNow: -59)
        let text = date.relativeText
        #expect(text == Text("recently"))
    }
}
