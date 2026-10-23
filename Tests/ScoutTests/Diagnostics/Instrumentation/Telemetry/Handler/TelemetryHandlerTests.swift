//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Metrics
import Testing

@testable import Scout
@testable import Support

struct TelemetryHandlerTests {
    @Test("TelemetryHandler stores label")
    func storesLabel() {
        let handler = TelemetryHandler(label: "test_label", dimensions: [], runtime: .stub)
        #expect(handler.label == "test_label")
    }

    @Test("TelemetryHandler stores dimensions")
    func storesDimensions() {
        let dims = [("key1", "value1"), ("key2", "value2")]
        let handler = TelemetryHandler(label: "test", dimensions: dims, runtime: .stub)
        #expect(handler.dimensions.count == 2)
        #expect(handler.dimensions[0].0 == "key1")
        #expect(handler.dimensions[1].1 == "value2")
    }

    @MainActor
    @Test("A non-finite floating counter increment is dropped", arguments: [Double.nan, .infinity, -.infinity])
    func dropsNonFiniteIncrement(value: Double) throws {
        let runtime = makeQueuedRuntime()
        let handler = TelemetryHandler(label: "test", dimensions: [], runtime: runtime)

        handler.increment(by: value)
        handler.increment(by: 1.5)

        let counters = try runtime.flushedContext().fetchAll(DoubleMetricsEntry.self)
        #expect(counters.map(\.value) == [1.5])
    }

    @MainActor
    @Test("A non-finite recording is dropped with its bucket count", arguments: [Double.nan, .infinity, -.infinity])
    func dropsNonFiniteRecording(value: Double) throws {
        let runtime = makeQueuedRuntime()
        let handler = TelemetryHandler(label: "test", dimensions: [], runtime: runtime)

        handler.record(value)
        handler.record(2.5)

        let context = try runtime.flushedContext()
        #expect(try context.fetchAll(DoubleMetricsEntry.self).map(\.value) == [2.5])
        #expect(try context.fetchAll(IntMetricsEntry.self).map(\.telemetry) == ["recorder_le_5"])
    }
}
