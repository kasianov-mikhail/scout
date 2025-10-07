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
}

extension ActivityPeriod {
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

extension ActivityPeriod: ChartTimeScale {
    var range: Range<Date> {
        let today = Calendar(identifier: .iso8601).startOfDay(for: Date())
        return today.adding(rangeComponent, value: -1)..<today
    }

    var rangeComponent: Calendar.Component {
        return .month
    }

    var pointComponent: Calendar.Component {
        return .day
    }
}
