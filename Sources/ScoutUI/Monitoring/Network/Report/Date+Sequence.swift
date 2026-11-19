//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {
    func dates(until end: Date, by component: Calendar.Component) -> [Date] {
        var result: [Date] = []
        var date = self

        while date < end {
            result.append(date)
            date = date.adding(component)
        }

        return result
    }
}
