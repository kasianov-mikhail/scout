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
@Suite("logMetrics")
struct LogMetricsTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSinceReferenceDate: 0)

    @Test("Persists an IntMetricsObject with correct fields")
    func persistsIntMetrics() throws {
        try logMetrics("api_calls", date: date, telemetry: .counter, value: 5, context)

        let request = NSFetchRequest<IntMetricsObject>(entityName: "IntMetricsObject")
        let results = try context.fetch(request)

        #expect(results.count == 1)

        let object = try #require(results.first)
        #expect(object.name == "api_calls")
        #expect(object.telemetry == "counter")
        #expect(object.value == 5)
        #expect(object.date == date)
    }

    @Test("Persists a DoubleMetricsObject with correct fields")
    func persistsDoubleMetrics() throws {
        try logMetrics("response_time", date: date, telemetry: .timer, value: 1.5, context)

        let request = NSFetchRequest<DoubleMetricsObject>(entityName: "DoubleMetricsObject")
        let results = try context.fetch(request)

        #expect(results.count == 1)

        let object = try #require(results.first)
        #expect(object.name == "response_time")
        #expect(object.telemetry == "timer")
        #expect(object.value == 1.5)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        try logMetrics("metric", date: date, telemetry: .counter, value: 1, context)

        #expect(!context.hasChanges)
    }
}
