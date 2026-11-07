//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import Testing

@testable import ScoutUI

@Suite("Hang severity")
struct HangSeverityTests {
    @Test("A hang shorter than 8 seconds is a warning")
    func belowThreshold() {
        #expect(Hang.stub(duration: 0).severity == .warning)
        #expect(Hang.stub(duration: 7.99).severity == .warning)
    }

    @Test("A hang of 8 seconds or longer is critical")
    func atThreshold() {
        #expect(Hang.stub(duration: 8).severity == .critical)
        #expect(Hang.stub(duration: 12.5).severity == .critical)
    }

    @Test("Each severity has its own label and icon")
    func labels() {
        #expect(HangSeverity.warning.label == "Hang")
        #expect(HangSeverity.critical.label == "Severe Hang")
        #expect(HangSeverity.warning.shortLabel == "Hang")
        #expect(HangSeverity.critical.shortLabel == "Severe")
        #expect(HangSeverity.warning.systemImage == "hourglass")
        #expect(HangSeverity.critical.systemImage == "exclamationmark.octagon")
    }
}
