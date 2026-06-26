//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct MatrixSpanTests {
    let range = Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8)

    // MARK: - Events

    @Test("Count excludes crashes and metrics")
    func countExcludesCrashesAndMetrics() {
        let span = makeSpan([
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
            makeMatrix(name: "purchase", date: Date(year: 2026, month: 6, day: 3), value: 4),
            makeMatrix(name: "Crash", date: Date(year: 2026, month: 6, day: 2), value: 2),
            makeMatrix(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
        ])

        #expect(span.total { $0 != CrashObject.recordType } == 7)
    }

    @Test("Count keeps points inside the range only")
    func countFiltersByRange() {
        let span = makeSpan([
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 1), value: 3),
            makeMatrix(name: "login", date: Date(year: 2026, month: 5, day: 20), value: 9),
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 8), value: 5),
        ])

        #expect(span.total { $0 != CrashObject.recordType } == 3)
    }

    // MARK: - Crashes

    @Test("Count sums the Crash matrices")
    func crashCount() {
        let span = makeSpan([
            makeMatrix(name: "Crash", date: Date(year: 2026, month: 6, day: 2), value: 2),
            makeMatrix(name: "Crash", date: Date(year: 2026, month: 5, day: 20), value: 4),
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
        ])

        #expect(span.total { $0 == CrashObject.recordType } == 2)
    }

    // MARK: - Metrics

    @Test("Metric count tallies distinct metrics across both matrix kinds")
    func metricCountIsDistinct() {
        let ints = makeSpan([
            makeMatrix(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
            makeMatrix(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 4), value: 1),
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
        ])
        let doubles = makeSpan([
            makeMatrix(name: "load_time", category: "timer", date: Date(year: 2026, month: 6, day: 3), value: 1.0),
            makeMatrix(name: "api_calls", category: "timer", date: Date(year: 2026, month: 6, day: 3), value: 1.0),
        ])

        #expect(ints.series + doubles.series == 3)
    }

    @Test("Metric count skips metrics without points in the range")
    func metricCountFiltersByRange() {
        let span = makeSpan([
            makeMatrix(name: "load_time", category: "timer", date: Date(year: 2026, month: 5, day: 20), value: 1.0)
        ])

        #expect(span.series == 0)
    }

    @Test("Metric count skips categories the Metrics list does not show")
    func metricCountSkipsHiddenCategories() {
        let span = makeSpan([
            makeMatrix(name: "memory", category: "meter_set", date: Date(year: 2026, month: 6, day: 2), value: 1.0)
        ])

        #expect(span.series == 0)
    }

    // MARK: - Factories

    /// A span already narrowed to `range`, matching how the log section consumes it.
    private func makeSpan<T: ChartNumeric>(_ matrices: [GridMatrix<T>]) -> MatrixSpan<T> {
        MatrixSpan(matrices: matrices, range: range)
    }

    /// A one-cell matrix whose single point lands exactly on `date`.
    private func makeMatrix<T: MetricScalar>(name: String, category: String? = nil, date: Date, value: T) -> GridMatrix<T> {
        Matrix(
            date: date,
            name: name,
            category: category,
            baseRecord: nil,
            cells: [GridCell(row: 1, column: 0, value: value)]
        )
    }
}
