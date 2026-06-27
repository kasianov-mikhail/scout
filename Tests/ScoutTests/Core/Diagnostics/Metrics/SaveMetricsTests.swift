//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("saveMetrics")
struct SaveMetricsTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSinceReferenceDate: 0)

    @Test("Persists an IntMetricsObject with correct fields")
    func persistsIntMetrics() throws {
        try saveMetrics("api_calls", date: date, telemetry: .counter, value: 5, context)

        let results = try context.fetchAll(IntMetricsObject.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        #expect(object.name == "api_calls")
        #expect(object.telemetry == "counter")
        #expect(object.value == 5)
        #expect(object.date == date)
    }

    @Test("Persists a DoubleMetricsObject with correct fields")
    func persistsDoubleMetrics() throws {
        try saveMetrics("response_time", date: date, telemetry: .timer, value: 1.5, context)

        let results = try context.fetchAll(DoubleMetricsObject.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        #expect(object.name == "response_time")
        #expect(object.telemetry == "timer")
        #expect(object.value == 1.5)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        try saveMetrics("metric", date: date, telemetry: .counter, value: 1, context)

        #expect(!context.hasChanges)
    }
}
