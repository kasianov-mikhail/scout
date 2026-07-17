//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics
import Testing

@testable import ScoutCore

struct TelemetryHandlerTests {
    @Test("TelemetryHandler stores label")
    func storesLabel() {
        let handler = TelemetryHandler(label: "test_label", dimensions: [], sync: {}, session: Protected(UUID()))
        #expect(handler.label == "test_label")
    }

    @Test("TelemetryHandler stores dimensions")
    func storesDimensions() {
        let dims = [("key1", "value1"), ("key2", "value2")]
        let handler = TelemetryHandler(label: "test", dimensions: dims, sync: {}, session: Protected(UUID()))
        #expect(handler.dimensions.count == 2)
        #expect(handler.dimensions[0].0 == "key1")
        #expect(handler.dimensions[1].1 == "value2")
    }
}
