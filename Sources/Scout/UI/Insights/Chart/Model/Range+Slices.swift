//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Range where Bound == Date {
    func slices(count: Int) -> [Range<Date>] {
        let step = upperBound.timeIntervalSince(lowerBound) / Double(count)

        guard step > 0 else {
            return []
        }

        return (0..<count).map { index in
            lowerBound.addingTimeInterval(step * Double(index))
                ..< lowerBound.addingTimeInterval(step * Double(index + 1))
        }
    }
}
