//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("Metrics matrix batching")
struct MetricsMatrixTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2026, month: 6, day: 1)

    @Test("Bucket increments aggregate into a matrix carrying the bucket category")
    func bucketCategory() throws {
        let batch = [
            makeBucketIncrement(category: "timer_le_100", date: date),
            makeBucketIncrement(category: "timer_le_100", date: date),
            makeBucketIncrement(category: "timer_le_100", date: date.addingHour()),
        ]

        let matrix = try IntMetricsObject.matrix(of: batch)

        #expect(type(of: matrix).recordType == "DateIntMatrix")
        #expect(matrix.category == "timer_le_100")
        #expect(matrix.name == "http_request")
        #expect(matrix.date == date.startOfWeek)
        #expect(matrix.cells.count == 2)
        #expect(matrix.cells.map(\.value).reduce(0, +) == 3)
    }

    @Test("Distinct bucket categories stay in separate batches by batch keys")
    func batchKeys() {
        #expect(IntMetricsObject.batchKeys.contains(\.telemetry))
    }

    private func makeBucketIncrement(category: String, date: Date) -> IntMetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "IntMetricsObject", in: context)!
        let metric = IntMetricsObject(entity: entity, insertInto: context)

        metric.name = "http_request"
        metric.telemetry = category
        metric.value = 1
        metric.date = date

        return metric
    }
}
