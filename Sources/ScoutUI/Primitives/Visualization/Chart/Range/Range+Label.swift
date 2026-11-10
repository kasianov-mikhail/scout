//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Range<Date> {
    func label(using formatter: DateFormatter, now: Date = .now) -> String {
        let from = formatter.string(from: lowerBound)
        let to = formatter.string(from: min(upperBound.addingDay(-1), now.startOfDay))

        guard from == to else {
            return "\(from) – \(to)"
        }
        return from
    }
}
