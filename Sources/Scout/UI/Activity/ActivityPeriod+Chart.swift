//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ActivityPeriod: ChartTimeScale {
    var horizonDate: Date { today }

    var rangeComponent: Calendar.Component { .month }

    var pointComponent: Calendar.Component { .day }
}
