//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A protocol that defines a model with date-related properties.
///
/// Types conforming to `DateModel` must provide properties for various date components,
/// such as the hour, day, week, and month. These properties are derived from the date
/// property, which is the primary date value.
///
protocol DateModel: AnyObject {

    /// The underlying date value.
    var datePrimitive: Date? { set get }

    var hour: Date? { set get }
    var day: Date? { set get }
    var week: Date? { set get }
    var month: Date? { set get }
}

extension DateModel {

    /// The primary date value.
    ///
    /// This property represents the primary date value for the model. When setting this property,
    /// the `hour`, `day`, `week`, and `month` properties are automatically updated to reflect the
    /// corresponding date components.
    ///
    /// - Note: The `date` property is a computed property that is not stored in the database.
    ///
    var date: Date? {
        get { datePrimitive }
        set {
            datePrimitive = newValue
            hour = newValue?.startOfHour
            day = newValue?.startOfDay
            week = newValue?.startOfWeek
            month = newValue?.startOfMonth
        }
    }
}

// MARK: - Date Fields

extension DateModel {

    /// A dictionary representation of the date fields.
    ///
    /// This property returns a dictionary containing the date fields of the model. The keys
    /// represent the field names, such as "hour", "day", "week", and "month", while the values
    /// represent the corresponding date values.
    ///
    /// - Note: Used in conjunction with `CKRepresentable` to convert the date fields to a
    /// dictionary that can be saved to CloudKit.
    ///
    var dateFields: [String: Date] {
        var fields: [String: Date] = [:]
        if let hour { fields["hour"] = hour }
        if let day { fields["day"] = day }
        if let week { fields["week"] = week }
        if let month { fields["month"] = month }
        return fields
    }
}

// MARK: - Conformances

extension TrackedObject: DateModel {}

extension UserActivity: DateModel {}

extension SessionObject: DateModel {}
