//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Array {

    /// Groups the elements of the collection by a specified date key path and returns a dictionary
    /// where the keys are strings representing the combination of the weekday and hour components
    /// of the date, and the values are the counts of elements in each group.
    ///
    /// - Parameter keyPath: A key path to the date property of the elements.
    /// - Returns: A dictionary where the keys are strings in the format `cell_<weekday>_<hour>`
    ///   and the values are the counts of elements in each group.
    ///
    func grouped(by keyPath: KeyPath<Element, Date?>) -> [String: Int] {
        Dictionary(grouping: self) {
            $0[keyPath: keyPath]
        }
        .reduce(into: [:]) { result, pair in
            if let key = pair.key {
                let week = Calendar.UTC.component(.weekday, from: key)
                let hour = Calendar.UTC.component(.hour, from: key)
                let components = ["cell", String(week), String(format: "%02d", hour)]
                let joined = components.joined(separator: "_")

                result[joined] = pair.value.count
            }
        }
    }
}
