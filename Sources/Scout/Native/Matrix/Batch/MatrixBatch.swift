//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MatrixBatch {
    associatedtype Cell: CellProtocol
    static func matrix(of batch: [Self]) throws -> Matrix<Cell>
}

extension NamedObject: MatrixBatch {
    static func matrix(of batch: [NamedObject]) throws -> GridMatrix<Int> {
        try Matrix(
            date: batch.seed(\.week),
            name: batch.seed(\.name),
            cells: gridCells(of: batch)
        )
    }
}

extension SessionObject {
    static func matrix(of batch: [SessionObject]) throws -> GridMatrix<Int> {
        try versionedMatrix(of: batch, appVersion: \.appVersion)
    }
}

extension CrashObject {
    static func matrix(of batch: [CrashObject]) throws -> GridMatrix<Int> {
        try versionedMatrix(of: batch, appVersion: \.appVersion)
    }
}

extension VersionMarker: MatrixBatch {
    static func matrix(of batch: [VersionMarker]) throws -> GridMatrix<Int> {
        try Matrix(
            date: batch.seed(\.week),
            name: batch.seed(\.name),
            version: batch.first?.appVersion,
            cells: gridCells(of: batch)
        )
    }
}

extension UserActivityObject: MatrixBatch {
    static func matrix(of batch: [UserActivityObject]) throws -> Matrix<PeriodCell<Int>> {
        try Matrix(
            date: batch.seed(\.month),
            name: "ActiveUser",
            cells: batch.compactMap(\.cell).mergeDuplicates()
        )
    }
}

extension UserActivityObject {
    fileprivate var cell: PeriodCell<Int>? {
        guard let month, let day else {
            return nil
        }
        guard let raw = period, let period = ActivityPeriod(rawValue: raw) else {
            return nil
        }
        guard let day = Calendar.utc.dateComponents([.day], from: month, to: day).day else {
            return nil
        }
        return PeriodCell(
            period: period,
            day: day,
            value: Int(self[keyPath: period.countField])
        )
    }
}

extension IntMetricsObject: MatrixBatch {}

extension DoubleMetricsObject: MatrixBatch {}

extension MetricsValued where Value: MetricScalar {
    static func matrix(of batch: [Self]) throws -> Matrix<GridCell<Value>> {
        let grouped = batch.grouped(by: \.hour).mapValues { items in
            items.reduce(.zero) { $0 + $1.value }
        }
        return try Matrix(
            date: batch.seed(\.week),
            name: batch.seed(\.name),
            category: batch.seed(\.telemetry),
            cells: grouped.map(GridCell.init)
        )
    }
}
