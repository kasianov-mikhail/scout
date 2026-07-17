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
        horizonDate.adding(rangeComponent, value: -1)..<horizonDate
    }

    var previousRange: Range<Date> {
        let range = initialRange
        return range.lowerBound.adding(rangeComponent, value: -1)..<range.lowerBound
    }
}
