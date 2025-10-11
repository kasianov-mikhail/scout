//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum ActivityPeriod: String, Identifiable, CaseIterable {
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

extension ActivityPeriod {
    var countField: ReferenceWritableKeyPath<UserActivity, Int32> {
        switch self {
        case .daily:
            \.dayCount
        case .weekly:
            \.weekCount
        case .monthly:
            \.monthCount
        }
    }

    var spreadComponent: Calendar.Component {
        switch self {
        case .daily:
            .day
        case .weekly:
            .weekOfYear
        case .monthly:
            .month
        }
    }
}

// MARK: - Chart

extension ActivityPeriod: ChartTimeScale {
    var horizonDate: Date {
        today
    }

    var rangeComponent: Calendar.Component {
        return .month
    }

    var pointComponent: Calendar.Component {
        return .day
    }
}
