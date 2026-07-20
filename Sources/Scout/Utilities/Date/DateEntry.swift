//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(DateEntry)
package class DateEntry: NSManagedObject {
    static let datePrimitiveKey = "datePrimitive"

    @NSManaged var datePrimitive: Date?
    @NSManaged var day: Date?
    @NSManaged var hour: Date?
    @NSManaged var month: Date?
    @NSManaged var week: Date?

    var references: Set<DateEntry> {
        []
    }

    // One-shot entries (device, install, version) are created once and never
    // re-created, so cleanup must keep them for backends configured later.
    var isPurgeable: Bool {
        true
    }

    var inferred: Date? {
        (references.map(\.datePrimitive) + [datePrimitive]).compactMap(\.self).max()
    }

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

    var metadata: [String: Any] {
        var fields: [String: Any] = [:]
        fields["hour"] = hour
        fields["day"] = day
        fields["week"] = week
        fields["month"] = month
        fields["version"] = 1
        return fields
    }
}
