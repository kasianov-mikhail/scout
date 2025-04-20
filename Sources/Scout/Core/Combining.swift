//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A protocol that defines the ability to combine objects by identifying duplicates
/// and merging their values.
///
/// Types conforming to this protocol must implement a method to check for duplicates
/// and an operator to merge two instances.
///
protocol Combining {

    /// Determines whether the current instance is a duplicate of another instance.
    ///
    /// - Parameter other: The instance to compare against.
    /// - Returns: `true` if the instances are considered duplicates, `false` otherwise.
    ///
    func isDuplicate(of other: Self) -> Bool

    /// Merges the values of two instances.
    ///
    /// - Parameters:
    ///   - lhs: The instance to be updated with the merged values.
    ///   - rhs: The instance whose values will be merged into `lhs`.
    ///
    static func += (lhs: inout Self, rhs: Self)
}

extension Array where Element: Combining {

    /// Merges duplicate elements in the array by combining their values.
    ///
    /// This method iterates through the array and checks for duplicates using the
    /// `isDuplicate(of:)` method. If a duplicate is found, the `+=` operator is used
    /// to merge the values. Otherwise, the element is added to the result array.
    ///
    /// - Returns: A new array with duplicates merged.
    ///
    func mergeDuplicates() -> Self {
        reduce(into: []) { result, value in
            if let index = result.firstIndex(where: {
                $0.isDuplicate(of: value)
            }) {
                result[index] += value
            } else {
                result.append(value)
            }
        }
    }
}
