//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import ScoutUI

struct ScaleStub: ChartTimeScale {
    let horizonDate: Date
    let rangeComponent: Calendar.Component
    var pointComponent = Calendar.Component.day

    var id: Date { horizonDate }
}
