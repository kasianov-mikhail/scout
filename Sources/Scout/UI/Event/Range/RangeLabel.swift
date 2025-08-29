//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Range<Date> {
    func rangeLabel(formatter: DateFormatter) -> String {
        let from = formatter.string(from: lowerBound)
        let to = formatter.string(from: upperBound.addingDay(-1))

        if from == to {
            return from
        } else {
            return "\(from) – \(to)"
        }
    }
}
