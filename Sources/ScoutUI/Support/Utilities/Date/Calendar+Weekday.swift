//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar {
    func mondayBasedWeekday(from date: Date) -> Int {
        (component(.weekday, from: date) + 5) % 7
    }
}
