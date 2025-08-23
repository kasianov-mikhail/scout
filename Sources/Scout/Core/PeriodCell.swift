//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

struct PeriodCell<T: MatrixValue & AdditiveArithmetic> {
    let period: ActivityPeriod
    let day: Int
    let value: T
}

extension PeriodCell: CellInitializable {
    init(key: String, value: T) throws {
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

        self.period = period
        self.day = day
        self.value = value
    }
}

extension PeriodCell: Combining {
    func isDuplicate(of other: Self) -> Bool {
        period == other.period && day == other.day
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func + (lhs: PeriodCell, rhs: PeriodCell) -> PeriodCell {

        // Ensure that the activity period and day match
        assert(lhs.period == rhs.period, "Cannot combine different periods")
        assert(lhs.day == rhs.day, "Cannot combine different days")

        return PeriodCell(
            period: lhs.period,
            day: lhs.day,
            value: lhs.value + rhs.value
        )
    }
}

extension PeriodCell: CustomStringConvertible {
    var description: String {
        "\(period) \(day): \(value)"
    }
}
