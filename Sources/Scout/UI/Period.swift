//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// An enumeration of statistical periods used to analyze data.
/// Each period represents a specific timeframe for the statistics being analyzed.
///
/// - Note: The period is used to group data points and visualize trends over time.
///
enum Period: String, Identifiable {

    /// An array of all statistical periods. The same as 'CaseIterable.allCases', but as a constant.
    static let all = [Period.today, .yesterday, .week, .month, .year]

    /// An array of all session-based statistical periods.
    static let sessions = [Period.week, .month, .year]

    case today
    case yesterday
    case week
    case month
    case year

    var id: Self { self }
}

// MARK: - Title

extension Period {

    /// A human-readable title for each statistical period.
    ///
    /// This property is used to display the period in a user-friendly format,
    /// making it easier for users to understand the timeframe being analyzed.
    ///
    var title: String {
        switch self {
        case .today:
            "Today"
        case .yesterday:
            "Yesterday"
        case .week:
            "Last 7 days"
        case .month:
            "Last 30 days"
        case .year:
            "Last 365 days"
        }
    }
}

// MARK: - Components

extension Period: ChartCompatible {

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

extension Period: CustomStringConvertible {
    var description: String {
        rawValue.capitalized
    }
}
