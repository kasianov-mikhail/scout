//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// A structure representing a cell in a matrix, identified by an activity period and a day,
/// and containing a value of a generic type.
///
/// - Generic Parameter T: The type of the value stored in the cell.
///
struct PeriodCell<T> {

    /// The activity period associated with the cell.
    let period: ActivityPeriod

    /// The day associated with the cell.
    let day: Int

    /// The value stored in the cell.
    let value: T
}

// MARK: - CellType

extension PeriodCell: CellType {
    typealias Value = T

    /// Initializes a `PeriodCell` with a key and a value.
    ///
    /// The key must be in the format `prefix_period_day`, where `period` is a valid `ActivityPeriod`
    /// and `day` is an integer. The value must be of the expected type `T`.
    ///
    /// - Parameters:
    ///   - key: A string representing the key in the format `prefix_period_day`.
    ///   - value: The value to be stored in the cell.
    ///
    /// - Precondition: The key must have three parts separated by underscores, and the `period` must
    ///   be a valid `ActivityPeriod`. The `day` must be a valid integer, and the value must be of type `T`.
    ///
    /// - Throws: A runtime error if the key format is invalid, the period is invalid, or the value type is incorrect.
    ///
    init(key: String, value: Any) throws {
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

        guard let value = value as? T else {
            fatalError("Invalid value type")
        }

        self.period = period
        self.day = day
        self.value = value
    }
}

// MARK: - Combining

extension PeriodCell: Combining where T: AdditiveArithmetic {

    /// Checks if the current cell is a duplicate of another cell.
    ///
    /// Two cells are considered duplicates if they have the same activity period and day.
    ///
    /// - Parameter other: The cell to compare against.
    /// - Returns: `true` if the cells are duplicates, `false` otherwise.
    ///
    func isDuplicate(of other: Self) -> Bool {
        period == other.period && day == other.day
    }

    /// Adds the values of two cells and assigns the result to the left-hand side cell.
    ///
    /// This operator adds the values of two cells that have the same activity period and day.
    /// The result is assigned to the left-hand side cell.
    ///
    /// - Parameters:
    ///   - lhs: The cell to be updated with the sum of the values.
    ///   - rhs: The cell whose value will be added to `lhs`.
    ///
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Adds the values of two cells and returns the result as a new cell.
    ///
    /// This operator adds the values of two cells that have the same activity period and day.
    /// The result is returned as a new cell.
    ///
    /// - Parameters:
    ///   - lhs: The first cell.
    ///   - rhs: The second cell.
    /// - Returns: A new cell with the sum of the values.
    /// - Precondition: The activity period and day of both cells must match.
    ///
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

// MARK: -

extension PeriodCell: CustomStringConvertible {

    /// A string representation of the cell.
    ///
    /// The description includes the activity period, day, and value of the cell.
    var description: String {
        "\(period) \(day): \(value)"
    }
}
