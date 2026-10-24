//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol ChartTimeScale: Identifiable, Hashable {
    var rangeComponent: Calendar.Component { get }
    var pointComponent: Calendar.Component { get }
    var horizonDate: Date { get }
}

extension ChartTimeScale {
    var today: Date {
        Date().startOfDay
    }

    var initialRange: Range<Date> {
        range(at: 0)
    }

    func range(at offset: Int) -> Range<Date> {
        horizonDate.adding(rangeComponent, value: offset - 1)..<horizonDate.adding(rangeComponent, value: offset)
    }

    var previousRange: Range<Date> {
        let range = initialRange
        return range.lowerBound.adding(rangeComponent, value: -1)..<range.lowerBound
    }
}
