//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Date {
    func addingHour(_ value: Int = 1) -> Date {
        adding(.hour, value: value)
    }

    mutating func addDay(_ value: Int = 1) {
        self = addingDay(value)
    }
}
