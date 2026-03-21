//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(DateObject)
class DateObject: NSManagedObject, Identifiable {
    @NSManaged var datePrimitive: Date?
    @NSManaged var day: Date?
    @NSManaged var hour: Date?
    @NSManaged var month: Date?
    @NSManaged var week: Date?

    var date: Date? {
        get {
            datePrimitive
        }
        set {
            datePrimitive = newValue
            hour = newValue?.startOfHour
            day = newValue?.startOfDay
            week = newValue?.startOfWeek
            month = newValue?.startOfMonth
        }
    }
}
