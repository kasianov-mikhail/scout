//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// The stat matrices backing the Home Log counters, with per-range counts
/// for each Log row.
///
/// Event matrices carry no category; their names are either lifecycle
/// record types or user event names, so event counts keep only the latter.
/// Metric matrices carry their telemetry category, and a metric is counted
/// when it reported at least once within the range.
///
struct HomeLogSummary {
    /// Metric categories surfaced by the Metrics list.
    static let metricCategories = Set(MetricsList.Scope.allCases.map(\.telemetry.rawValue))

    let intMatrices: [GridMatrix<Int>]
    let doubleMatrices: [GridMatrix<Double>]

    /// Total number of logged events within `range`.
    func eventCount(in range: Range<Date>) -> Int {
        eventTotal(in: range) { !LifecycleMatrix.names.contains($0) }
    }

    /// Total number of crashes within `range`.
    func crashCount(in range: Range<Date>) -> Int {
        eventTotal(in: range) { $0 == CrashObject.recordType }
    }

    /// Number of metrics that reported at least once within `range`.
    func metricCount(in range: Range<Date>) -> Int {
        metricKeys(of: intMatrices, in: range)
            .union(metricKeys(of: doubleMatrices, in: range))
            .count
    }

    private func eventTotal(in range: Range<Date>, where isIncluded: (String) -> Bool) -> Int {
        intMatrices
            .filter { $0.category == nil && isIncluded($0.name) }
            .flatMap(\.points)
            .filter { range.contains($0.date) }
            .total
    }

    private func metricKeys<T: MatrixValue & ChartNumeric>(of matrices: [GridMatrix<T>], in range: Range<Date>) -> Set<MetricKey> {
        let keys = matrices.compactMap { matrix -> MetricKey? in
            guard let category = matrix.category, Self.metricCategories.contains(category) else {
                return nil
            }
            guard matrix.cells.contains(where: { range.contains($0.point(baseDate: matrix.date).date) }) else {
                return nil
            }
            return MetricKey(category: category, name: matrix.name)
        }
        return Set(keys)
    }

    /// Identity of a metric: the same name may exist in several categories.
    private struct MetricKey: Hashable {
        let category: String
        let name: String
    }
}
