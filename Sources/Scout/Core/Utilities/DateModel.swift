//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol DateModel: AnyObject {
    var datePrimitive: Date? { set get }

    var hour: Date? { set get }
    var day: Date? { set get }
    var week: Date? { set get }
    var month: Date? { set get }
}

extension DateModel {
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

extension DateModel {
    var dateFields: [String: Date] {
        var fields: [String: Date] = [:]
        if let hour { fields["hour"] = hour }
        if let day { fields["day"] = day }
        if let week { fields["week"] = week }
        if let month { fields["month"] = month }
        return fields
    }
}

extension TrackedObject: DateModel {}

extension UserActivity: DateModel {}

extension SessionObject: DateModel {}
