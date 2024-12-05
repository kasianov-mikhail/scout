//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Range<Date> {

    /// Generates a label for the date range using the provided date formatter.
    ///
    /// - Parameter formatter: The `DateFormatter` used to format the dates.
    /// - Returns: A string representing the date range. If the start and end dates are the same, 
    ///   it returns a single date. Otherwise, it returns a range in the format "from – to".
    ///
    func rangeLabel(formatter: DateFormatter) -> String {
        let from = formatter.string(from: lowerBound)
        let to = formatter.string(from: upperBound.addingDay(-1))

        if from == to {
            return from
        } else {
            return "\(from) – \(to)"
        }
    }
}
