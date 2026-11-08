//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@Suite("MetricValueFormat")
struct MetricValueFormatTests {
    @Test("Counters group digits and compact in tiles")
    func counter() {
        #expect(MetricValueFormat.counter.label(1_284) == "1,284")
        #expect(MetricValueFormat.counter.label(42_100, compact: true) == "42.1K")
        #expect(MetricValueFormat.counter.label(999) == "999")
    }

    @Test("Floating counters keep decimals and compact in tiles")
    func floating() {
        #expect(MetricValueFormat.floating.label(118.4) == "118.4")
        #expect(MetricValueFormat.floating.label(18_400, compact: true) == "18.4K")
    }

    @Test("Timers print a duration")
    func timer() {
        #expect(MetricValueFormat.timer.label(0.081) == "81 ms")
        #expect(MetricValueFormat.timer.label(3.8) == "3.8 s")
    }

    @Test("Recorders and meters drop a zero fraction")
    func plainNumbers() {
        #expect(MetricValueFormat.recorder.label(284) == "284")
        #expect(MetricValueFormat.meter.label(3) == "3")
        #expect(MetricValueFormat.meter.label(9.8) == "9.8")
    }
}
