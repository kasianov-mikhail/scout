//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Date {
    func adding(_ component: Calendar.Component, value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: component, value: value, to: self)!
    }

    func addingMonth(_ value: Int = 1) -> Date {
        Calendar.utc.date(byAdding: .month, value: value, to: self)!
    }

    var trailingYear: Range<Date> {
        let today = startOfDay
        return today.addingYear(-1).addingWeek(-1)..<today.addingDay()
    }
}
