//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
struct GaugeHandlerTests {
    @Test("A non-finite reading is dropped and keeps the running value", arguments: [Double.nan, .infinity, -.infinity])
    func dropsNonFiniteReading(value: Double) throws {
        let runtime = makeQueuedRuntime()
        let handler = GaugeHandler(label: "gauge", runtime: runtime)

        handler.set(2.0)
        handler.set(value)
        handler.increment(by: value)
        handler.decrement(by: value)
        handler.increment(by: 1.0)

        #expect(handler.value.current == 3)

        let meters = try runtime.flushedContext().fetchAll(DoubleMetricsEntry.self)
        #expect(meters.map(\.value).sorted() == [2, 3])
    }
}
