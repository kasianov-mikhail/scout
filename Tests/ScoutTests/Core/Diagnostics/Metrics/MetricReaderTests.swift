//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct MetricReaderTests {
    @Test("Rebuilds an int metric series from grid matrices")
    func reconstructsIntSeries() async throws {
        let database = DatabaseStub()
        database.add(
            GridMatrix<Int>(
                date: date(2026, 6, 8),
                name: "api_calls",
                category: "counter",
                baseRecord: nil,
                cells: [
                    GridCell(row: 4, column: 9, value: 2),  // +3 days, +9h
                    GridCell(row: 4, column: 10, value: 3),
                ]
            ).record
        )

        let series = try await database.metricSeries(
            Int.self,
            category: "counter",
            in: date(2026, 6, 1)..<date(2026, 7, 1)
        )

        #expect(series.count == 1)

        let calls = try #require(series.first)
        #expect(calls.name == "api_calls")
        #expect(calls.category == "counter")
        #expect(calls.points.count == 2)
        // Grid coordinates resolve back to the original hours and values.
        #expect(calls.points.contains { $0.date == ms(2026, 6, 11, 9) && $0.value == .int(2) })
        #expect(calls.points.contains { $0.date == ms(2026, 6, 11, 10) && $0.value == .int(3) })
    }

    @Test("Rebuilds a double metric series from grid matrices")
    func reconstructsDoubleSeries() async throws {
        let database = DatabaseStub()
        database.add(
            GridMatrix<Double>(
                date: date(2026, 6, 8),
                name: "latency",
                category: "gauge",
                baseRecord: nil,
                cells: [GridCell(row: 1, column: 0, value: 1.5)]
            ).record
        )

        let series = try await database.metricSeries(
            Double.self,
            category: "gauge",
            in: date(2026, 6, 1)..<date(2026, 7, 1)
        )

        let latency = try #require(series.first)
        #expect(latency.points.first?.value == .double(1.5))
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0) -> Date {
        DateComponents(calendar: .utc, year: year, month: month, day: day, hour: hour).date!
    }

    private func ms(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Int64 {
        Int64((date(year, month, day, hour).timeIntervalSince1970 * 1000).rounded())
    }
}
