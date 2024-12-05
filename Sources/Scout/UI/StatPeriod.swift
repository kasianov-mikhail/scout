//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// An enumeration representing different statistical periods.
/// This can be used to categorize or filter data based on different time periods.
///
enum StatPeriod: String, CaseIterable, Identifiable {
    case today
    case yesterday
    case week
    case month
    case year

    var id: Self { self }
}

// MARK: - Components

extension StatPeriod {

    /// A computed property that returns the date range for each statistical period.
    /// This property is used to visualize data for a specific period,
    /// providing a clear timeframe for the statistics being analyzed.
    ///
    var range: Range<Date> {
        let today = Calendar(identifier: .iso8601).startOfDay(for: Date())

        return switch self {
        case .today:
            today..<today.adding(rangeComponent)
        default:
            today.adding(rangeComponent, value: -1)..<today
        }
    }

    /// The calendar component used to calculate the date range for each statistical period.
    /// This property helps in determining the length of the date range for each period.
    ///
    var rangeComponent: Calendar.Component {
        switch self {
        case .today, .yesterday:
            .day
        case .week:
            .weekOfYear
        case .month:
            .month
        case .year:
            .year
        }
    }

    /// The calendar component used to group data points within the statistical period.
    /// This property helps in determining the granularity of the data points for each period.
    ///
    var pointComponent: Calendar.Component {
        switch self {
        case .today, .yesterday:
            .hour
        case .week, .month:
            .day
        case .year:
            .month
        }
    }
}

// MARK: -

extension StatPeriod: CustomStringConvertible {
    var description: String {
        rawValue.capitalized
    }
}
