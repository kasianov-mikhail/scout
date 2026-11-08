//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@Suite("MetricHistogramLayout")
struct MetricHistogramLayoutTests {
    @Test("Log interpolation places a percentile inside its bucket")
    func position() {
        let layout = MetricHistogramLayout(counts: [1, 2, 3], bounds: [1, 2, 3])

        #expect(abs(layout.position(0.5) - 0.125) < 0.000_001)
        #expect(abs(layout.position(2) - 0.5) < 0.000_001)
        #expect(layout.position(10) == 1)
    }

    @Test("Bars scale to the tallest bucket")
    func fraction() {
        let layout = MetricHistogramLayout(counts: [1, 2, 4], bounds: [1, 2])

        #expect(layout.fraction(4) == 1)
        #expect(layout.fraction(2) == 0.5)
        #expect(layout.fraction(0) == 0)
    }

    @Test("Labels leave room for at most eight values")
    func labelIndices() {
        let layout = MetricHistogramLayout(counts: Array(repeating: 1, count: 15), bounds: Array(repeating: 1, count: 14))

        #expect(layout.labelIndices == [0, 2, 4, 6, 8, 10, 12, 14])
    }

    @Test("Timer labels switch from milliseconds to seconds")
    func timerLabels() {
        #expect(MetricHistogramFormat.timer.label(0.001) == "1")
        #expect(MetricHistogramFormat.timer.label(0.5) == "500")
        #expect(MetricHistogramFormat.timer.label(2.5) == "2.5s")
        #expect(MetricHistogramFormat.timer.label(10) == "10s")
        #expect(MetricHistogramFormat.timer.overflowLabel(30) == ">30s")
    }

    @Test("Recorder labels compact large bounds")
    func recorderLabels() {
        #expect(MetricHistogramFormat.recorder.label(20) == "20")
        #expect(MetricHistogramFormat.recorder.label(2_000) == "2k")
        #expect(MetricHistogramFormat.recorder.label(200_000) == "200k")
        #expect(MetricHistogramFormat.recorder.overflowLabel(1_000_000) == ">1M")
    }
}
