//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar {
    var defaultRange: ClosedRange<Date> {
        let today = Date().startOfDay
        let yearAgo = today.addingYear(-1).addingWeek(-1)
        let tomorrow = today.addingDay()
        return yearAgo...tomorrow
    }
}
