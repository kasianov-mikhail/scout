//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct TelemetryExportTests {
    @Test("Export raw values match expected strings")
    func exportRawValues() {
        #expect(Telemetry.Export.counter.rawValue == "counter")
        #expect(Telemetry.Export.floatingCounter.rawValue == "floating_counter")
        #expect(Telemetry.Export.meter.rawValue == "meter")
        #expect(Telemetry.Export.recorder.rawValue == "recorder")
        #expect(Telemetry.Export.timer.rawValue == "timer")
    }

    @Test("Export allCases contains all five types")
    func exportAllCases() {
        #expect(Telemetry.Export.allCases.count == 5)
    }
}
