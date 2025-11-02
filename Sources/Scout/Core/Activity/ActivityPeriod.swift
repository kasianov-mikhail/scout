//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum ActivityPeriod: String, Identifiable, CaseIterable, Equatable {
    case daily = "d"
    case weekly = "w"
    case monthly = "m"

    var id: Self { self }

    var title: String {
        switch self {
        case .daily:
            "Daily"
        case .weekly:
            "Weekly"
        case .monthly:
            "Monthly"
        }
    }
}

extension ActivityPeriod: ChartTimeScale {
    var horizonDate: Date { today }

    var rangeComponent: Calendar.Component { .month }

    var pointComponent: Calendar.Component { .day }
}
