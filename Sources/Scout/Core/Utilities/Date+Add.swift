//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {
    func adding(_ component: Calendar.Component, value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: component, value: value, to: self)!
    }

    func addingDay(_ value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: .day, value: value, to: self)!
    }

    func addingHour(_ value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: .hour, value: value, to: self)!
    }

    func addingWeek(_ value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: .weekOfYear, value: value, to: self)!
    }

    func addingMonth(_ value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: .month, value: value, to: self)!
    }

    func addingYear(_ value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: .year, value: value, to: self)!
    }
}

extension Date {
    mutating func add(_ component: Calendar.Component, value: Int = 1) {
        self = adding(component, value: value)
    }

    mutating func addDay(_ value: Int = 1) {
        self = addingDay(value)
    }

    mutating func addHour(_ value: Int = 1) {
        self = addingHour(value)
    }

    mutating func addWeek(_ value: Int = 1) {
        self = addingWeek(value)
    }

    mutating func addMonth(_ value: Int = 1) {
        self = addingMonth(value)
    }

    mutating func addYear(_ value: Int = 1) {
        self = addingYear(value)
    }
}
