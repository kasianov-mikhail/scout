//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ActivityPeriod {

    /// Selects the per-period counter used for DAU/WAU/MAU.
    ///
    /// - `.daily`   -> daily active users (DAU) via `UserActivity.dayCount`
    /// - `.weekly`  -> weekly active users (WAU) via `UserActivity.weekCount`
    /// - `.monthly` -> monthly active users (MAU) via `UserActivity.monthCount`
    ///
    /// This key path lets aggregation and update code address the correct metric
    /// without branching on the period.
    ///
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

    /// Defines the calendar span for the metric window:
    ///
    /// - `.daily`   -> `.day` (DAU window)
    /// - `.weekly`  -> `.weekOfYear` (WAU window)
    /// - `.monthly` -> `.month` (MAU window)
    ///
    /// Used to build half‑open ranges and period limits when collecting and
    /// aggregating activity for DAU/WAU/MAU.
    ///
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
