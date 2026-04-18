//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Metrics
import Testing

@testable import Scout

struct TelemetryHandlerTests {
    @Test("CKTelemetryHandler stores label")
    func storesLabel() {
        let handler = CKTelemetryHandler(label: "test_label", dimensions: [], sync: {})
        #expect(handler.label == "test_label")
    }

    @Test("CKTelemetryHandler stores dimensions")
    func storesDimensions() {
        let dims = [("key1", "value1"), ("key2", "value2")]
        let handler = CKTelemetryHandler(label: "test", dimensions: dims, sync: {})
        #expect(handler.dimensions.count == 2)
        #expect(handler.dimensions[0].0 == "key1")
        #expect(handler.dimensions[1].1 == "value2")
    }
}
