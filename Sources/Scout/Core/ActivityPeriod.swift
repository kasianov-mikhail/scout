//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Represents the period of time for which active users are tracked.
///
/// The active user period can be daily, weekly, or monthly. This can be used to
/// track the number of active users over a specific period of time. For example,
/// you can track the number of daily active users, weekly active users, or monthly
/// active users.
///
enum ActivityPeriod: String, Identifiable, CaseIterable {
    case daily
    case weekly
    case monthly

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

    var rangeComponent: Calendar.Component {
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
