//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension SeriesBucket {
    func range(startingOn date: Date) -> Range<Date> {
        let start = self.start(of: date)

        return switch self {
        case .hour: start..<start.adding(.hour)
        case .day: start..<start.addingDay()
        case .week: start..<start.addingWeek()
        }
    }
}
