//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ChartCompatible: Identifiable, Hashable {
    var pointComponent: Calendar.Component { get }
    var rangeComponent: Calendar.Component { get }
    var range: Range<Date> { get }
}

extension Array where Element: ChartCompatible {
    var uniqueComponents: Set<Calendar.Component> {
        Set(map(\.pointComponent))
    }
}
