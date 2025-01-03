//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKRecord {

    /// A computed property that retrieves the `hour` field from the CKRecord and converts it to a string identifier.
    /// The identifier is generated based on the current date and time in the format `cell_week_hour`.
    ///
    /// - Returns: A string in the format `cell_week_hour`, where `week` is the current weekday
    ///   and `hour` is the current hour formatted as a two-digit number.
    ///
    var hourField: String {
        let hour = self["hour"] as! Date
        return hour.field
    }
}

extension Date {

    /// A computed property that returns a string representing the field, used for grouping events by hour.
    fileprivate var field: String {
        let week = Calendar.UTC.component(.weekday, from: self)
        let hour = Calendar.UTC.component(.hour, from: self)
        let components = ["cell", String(week), String(format: "%02d", hour)]
        return components.joined(separator: "_")
    }
}
