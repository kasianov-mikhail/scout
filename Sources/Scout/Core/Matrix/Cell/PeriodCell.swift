//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct PeriodCell<T: MatrixValue> {
    static var recordType: String { "PeriodMatrix" }

    let period: ActivityPeriod
    let day: Int
    let value: T
}

// MARK: - Matrix

extension PeriodCell: CellProtocol {
    var key: String {
        "cell_\(period.rawValue)_\((day + 1).leadingZero)"
    }

    init(key: String, value: T) {
        guard let parts = parseCellKey(key) else {
            fatalError("Invalid key format")
        }
        guard let period = ActivityPeriod(rawValue: parts.first) else {
            fatalError("Invalid period")
        }
        guard let day = Int(parts.second) else {
            fatalError("Invalid day")
        }

        self.init(period: period, day: day - 1, value: value)
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
