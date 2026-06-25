//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct HomeLogSectionTests {
    let range = Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8)

    // MARK: - Events

    @Test("Event count excludes crashes and metrics")
    func eventCountExcludesCrashesAndMetrics() {
        let intMatrices = [
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
            makeMatrix(name: "purchase", date: Date(year: 2026, month: 6, day: 3), value: 4),
            makeMatrix(name: "Crash", date: Date(year: 2026, month: 6, day: 2), value: 2),
            makeMatrix(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
        ]

        #expect(HomeEventSection(intMatrices: intMatrices, range: range).count == 7)
    }

    @Test("Event count keeps points inside the range only")
    func eventCountFiltersByRange() {
        let intMatrices = [
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 1), value: 3),
            makeMatrix(name: "login", date: Date(year: 2026, month: 5, day: 20), value: 9),
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 8), value: 5),
        ]

        #expect(HomeEventSection(intMatrices: intMatrices, range: range).count == 3)
    }

    // MARK: - Crashes

    @Test("Crash count sums the Crash matrices")
    func crashCount() {
        let intMatrices = [
            makeMatrix(name: "Crash", date: Date(year: 2026, month: 6, day: 2), value: 2),
            makeMatrix(name: "Crash", date: Date(year: 2026, month: 5, day: 20), value: 4),
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
        ]

        #expect(HomeCrashSection(intMatrices: intMatrices, range: range).count == 2)
    }

    // MARK: - Metrics

    @Test("Metric count tallies distinct metrics across both matrix kinds")
    func metricCountIsDistinct() {
        let intMatrices = [
            makeMatrix(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 2), value: 7),
            makeMatrix(name: "api_calls", category: "counter", date: Date(year: 2026, month: 6, day: 4), value: 1),
            makeMatrix(name: "login", date: Date(year: 2026, month: 6, day: 2), value: 3),
        ]
        let doubleMatrices = [
            makeMatrix(name: "load_time", category: "timer", date: Date(year: 2026, month: 6, day: 3), value: 1.0),
            makeMatrix(name: "api_calls", category: "timer", date: Date(year: 2026, month: 6, day: 3), value: 1.0),
        ]

        #expect(HomeMetricsSection(intMatrices: intMatrices, doubleMatrices: doubleMatrices, range: range).count == 3)
    }

    @Test("Metric count skips metrics without points in the range")
    func metricCountFiltersByRange() {
        let doubleMatrices = [
            makeMatrix(name: "load_time", category: "timer", date: Date(year: 2026, month: 5, day: 20), value: 1.0)
        ]

        #expect(HomeMetricsSection(intMatrices: [], doubleMatrices: doubleMatrices, range: range).count == 0)
    }

    @Test("Metric count skips categories the Metrics list does not show")
    func metricCountSkipsHiddenCategories() {
        let doubleMatrices = [
            makeMatrix(name: "memory", category: "meter_set", date: Date(year: 2026, month: 6, day: 2), value: 1.0)
        ]

        #expect(HomeMetricsSection(intMatrices: [], doubleMatrices: doubleMatrices, range: range).count == 0)
    }

    // MARK: - Factories

    /// A one-cell matrix whose single point lands exactly on `date`.
    private func makeMatrix<T: MatrixValue>(name: String, category: String? = nil, date: Date, value: T) -> GridMatrix<T> {
        Matrix(
            date: date,
            name: name,
            category: category,
            baseRecord: nil,
            cells: [GridCell(row: 1, column: 0, value: value)]
        )
    }
}
