//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension UserActivity: MatrixBatch {
    static func matrix(of batch: [UserActivity]) throws(MatrixPropertyError) -> Matrix<PeriodCell<Int>> {
        guard let month = batch.first?.month else {
            throw .init("month")
        }
        return Matrix(
            recordType: "PeriodMatrix",
            date: month,
            name: "ActiveUser",
            cells: parse(of: batch)
        )
    }

    static func parse(of batch: [UserActivity]) -> [PeriodCell<Int>] {
        batch.compactMap(\.cell).mergeDuplicates()
    }

    private var cell: PeriodCell<Int>? {
        guard let month, let day else {
            return nil
        }
        guard let raw = period, let period = ActivityPeriod(rawValue: raw) else {
            return nil
        }
        return PeriodCell(
            period: period,
            day: Calendar.utc.dateComponents([.day], from: month, to: day).day ?? 0,
            value: Int(self[keyPath: period.countField])
        )
    }
}
