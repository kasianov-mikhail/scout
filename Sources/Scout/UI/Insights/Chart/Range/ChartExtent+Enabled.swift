//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartExtent {
    var isLeftEnabled: Bool {
        let yearRange = Period.year.initialRange
        let leftRange = domain.moved(by: period.rangeComponent, value: -1)
        return yearRange.lowerBound < leftRange.lowerBound
    }

    var isRightEnabled: Bool {
        domain != period.initialRange
    }
}
