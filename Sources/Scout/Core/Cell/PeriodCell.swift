//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct PeriodCell<T: MatrixValue> {
    let period: ActivityPeriod
    let day: Int
    let value: T
}

// MARK: - Matrix

typealias PeriodMatrix = Matrix<PeriodCell<Int>>

extension PeriodCell: CellProtocol {
    var key: String {
        "cell_\(period.rawValue)_\((day + 1).leadingZero)"
    }

    init(key: String, value: T) {
        let parts = key.components(separatedBy: "_")

        guard parts.count == 3 else {
            fatalError("Invalid key format")
        }
        guard let period = ActivityPeriod(rawValue: String(parts[1])) else {
            fatalError("Invalid period")
        }
        guard let day = Int(parts[2]) else {
            fatalError("Invalid day")
        }

        self.init(period: period, day: day, value: value)
    }
}

// MARK: - Combining

extension PeriodCell: Combining {
    func isDuplicate(of other: Self) -> Bool {
        period == other.period && day == other.day
    }

    static func + (lhs: PeriodCell, rhs: PeriodCell) -> PeriodCell {
        PeriodCell(
            period: lhs.period,
            day: lhs.day,
            value: lhs.value + rhs.value
        )
    }
}

// MARK: -

extension PeriodCell: CustomStringConvertible {
    var description: String {
        "\(period) \(day): \(value)"
    }
}
