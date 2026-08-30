//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct AlertScale: ChartTimeScale {
    let horizonDate: Date

    var id: Date { horizonDate }
    var rangeComponent: Calendar.Component { .day }
    var pointComponent: Calendar.Component { .hour }
}

extension AlertScale {
    static var trailing: AlertScale {
        AlertScale(horizonDate: Date().startOfHour)
    }
}
