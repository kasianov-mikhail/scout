//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct DeviceSession: Identifiable {
    let id: String
    let sessionID: UUID?
    let startDate: Date
    let endDate: Date?
    let appVersion: String?
    let crashed: Bool

    var time: String {
        deviceSessionTimeFormatter.string(from: startDate)
    }

    var duration: TimeInterval? {
        guard let endDate, endDate >= startDate else {
            return nil
        }
        return endDate.timeIntervalSince(startDate)
    }

    var durationText: String? {
        duration?.deviceLength
    }
}

struct DeviceActivityPoint: Identifiable {
    let date: Date
    let label: String
    let count: Int
    let showsLabel: Bool
    let isCurrent: Bool

    var id: Date {
        date
    }
}

extension DeviceActivityPoint {
    static func points(sessions: [Session], range: IncidentRange, now: Date) -> [DeviceActivityPoint] {
        let bounds = range.range(now: now)
        let dates = sessions.compactMap(\.startDate)

        guard range != .year else {
            return months(dates: dates, bounds: bounds)
        }

        return days(dates: dates, bounds: bounds, range: range)
    }

    private static func days(dates: [Date], bounds: Range<Date>, range: IncidentRange) -> [DeviceActivityPoint] {
        var points: [DeviceActivityPoint] = []
        var day = bounds.lowerBound.startOfDay

        while day < bounds.upperBound {
            let next = day.addingDay()
            let index = points.count
            points.append(
                DeviceActivityPoint(
                    date: day,
                    label: range == .week ? deviceWeekdayFormatter.string(from: day) : deviceDayFormatter.string(from: day),
                    count: dates.filter { $0 >= day && $0 < next }.count,
                    showsLabel: range == .week || index.isMultiple(of: 5) || day == bounds.upperBound.addingDay(-1),
                    isCurrent: next >= bounds.upperBound
                )
            )
            day = next
        }

        return points
    }

    private static func months(dates: [Date], bounds: Range<Date>) -> [DeviceActivityPoint] {
        var points: [DeviceActivityPoint] = []
        var month = bounds.lowerBound.startOfMonth

        while month < bounds.upperBound {
            let next = month.addingMonth()
            points.append(
                DeviceActivityPoint(
                    date: month,
                    label: deviceMonthFormatter.string(from: month),
                    count: dates.filter { $0 >= month && $0 < next }.count,
                    showsLabel: true,
                    isCurrent: next >= bounds.upperBound
                )
            )
            month = next
        }

        return points
    }
}

extension TimeInterval {
    var deviceLength: String {
        let minutes = Int((self / 60).rounded())

        if minutes >= 60 {
            let hours = minutes / 60
            let rest = minutes % 60
            return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
        }
        if minutes > 0 {
            return "\(minutes) min"
        }
        return "\(Int(max(self, 0).rounded())) s"
    }
}

let deviceSessionTimeFormatter = DateFormatter(format: "EEE HH:mm")
let deviceWeekdayFormatter = DateFormatter(format: "EEE")
let deviceDayFormatter = DateFormatter(format: "d")
let deviceMonthFormatter = DateFormatter(format: "MMM")
