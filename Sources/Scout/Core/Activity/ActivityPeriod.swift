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
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }
}

extension ActivityPeriod {
    var countField: ReferenceWritableKeyPath<UserActivity, Int32> {
        switch self {
        case .daily:
            return \.dayCount
        case .weekly:
            return \.weekCount
        case .monthly:
            return \.monthCount
        }
    }

    var spreadComponent: Calendar.Component {
        switch self {
        case .daily:
            return .day
        case .weekly:
            return .weekOfYear
        case .monthly:
            return .month
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
