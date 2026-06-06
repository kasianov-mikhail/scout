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

    init(key: String, value: T) throws {
        let parts = key.components(separatedBy: "_")

        guard parts.count == 3 else {
            throw CellKeyError.malformed(key)
        }
        guard let period = ActivityPeriod(rawValue: String(parts[1])) else {
            throw CellKeyError.invalidComponent(field: "period", value: parts[1])
        }
        guard let day = Int(parts[2]) else {
            throw CellKeyError.invalidComponent(field: "day", value: parts[2])
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
