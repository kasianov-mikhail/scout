//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DeviceDetail {
    let summary: DeviceSummary
    let crashes: Int
    let hangs: Int
    let resources: Int
    let recentSessions: [DeviceSession]
    let history: [DeviceHistoryEvent]
    let activity: [DeviceActivityPoint]
    let usage: DeviceUsage
    let range: IncidentRange
    let medianDuration: TimeInterval?

    var maxSessionDuration: TimeInterval {
        recentSessions.compactMap(\.duration).max() ?? 0
    }

    var activeDaysLabel: String {
        let active = activity.filter { $0.count > 0 }.count
        let unit = range == .year ? "month" : "day"
        return "\(active) of \(activity.count) \(unit)s"
    }

    var activityCaption: String {
        let unit = range == .year ? "month" : "day"
        var parts = ["Sessions per \(unit)"]

        if let medianDuration {
            parts.append("median length \(medianDuration.deviceLength)")
        }
        if let window = usage.busiestWindow {
            parts.append("most active \(window)")
        }

        return parts.joined(separator: " · ")
    }

    var usageCaption: String {
        guard let window = usage.busiestWindow else {
            return "No sessions in this period"
        }
        return "Most activity \(window), in UTC"
    }
}

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

extension DeviceDetail {
    init(summary: DeviceSummary, range: IncidentRange, sessions: [Session], crashes: [Crash], hangs: [Hang], resources: [ResourceException], installs: [Install], versions: [Version], now: Date) {
        let crashSessions = Set(crashes.compactMap(\.sessionID))
        let recent =
            sessions
            .sorted { ($0.startDate ?? .distantPast) > ($1.startDate ?? .distantPast) }
            .prefix(5)
            .compactMap { session -> DeviceSession? in
                guard let startDate = session.startDate else {
                    return nil
                }
                return DeviceSession(
                    id: session.id,
                    sessionID: session.sessionID,
                    startDate: startDate,
                    endDate: session.endDate,
                    appVersion: session.appVersion,
                    crashed: session.sessionID.map(crashSessions.contains) ?? false
                )
            }

        self.init(
            summary: summary,
            crashes: crashes.count,
            hangs: hangs.count,
            resources: resources.count,
            recentSessions: Array(recent),
            history: [DeviceHistoryEvent](installs: installs, versions: versions, sessions: sessions),
            activity: DeviceActivityPoint.points(sessions: sessions, range: range, now: now),
            usage: DeviceUsage(sessions: sessions),
            range: range,
            medianDuration: sessions.compactMap(\.duration).median
        )
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

extension Session {
    fileprivate var duration: TimeInterval? {
        guard let startDate, let endDate, endDate >= startDate else {
            return nil
        }
        return endDate.timeIntervalSince(startDate)
    }
}

extension DeviceDetail {
    static var sample: DeviceDetail {
        let now = Date()
        let sessions = (0..<5).map { index in
            let start = now.addingTimeInterval(-Double(index) * 3_600 - 600)
            return DeviceSession(
                id: UUID().uuidString,
                sessionID: UUID(),
                startDate: start,
                endDate: start.addingTimeInterval(Double(5 - index) * 60),
                appVersion: "2.4.1",
                crashed: index == 1
            )
        }
        let sessionCounts = [96, 120, 88, 0, 140, 130, 146]
        let activity = (0..<7).map { index in
            DeviceActivityPoint(
                date: now.startOfDay.addingDay(index - 6),
                label: deviceWeekdayFormatter.string(from: now.startOfDay.addingDay(index - 6)),
                count: sessionCounts[index],
                showsLabel: true,
                isCurrent: index == 6
            )
        }
        let usageCounts = (0..<7).map { day in
            (0..<24).map { hour in
                max(0, Int((exp(-pow(Double(hour) - 20, 2) / 8) * (day < 5 ? 1 : 0.6) + 0.05) * 20))
            }
        }

        return DeviceDetail(
            summary: DeviceSummary.samples[0],
            crashes: 2,
            hangs: 1,
            resources: 2,
            recentSessions: sessions,
            history: [
                DeviceHistoryEvent(id: "updated", date: now.addingTimeInterval(-86_400), kind: .updated(version: "2.4.1")),
                DeviceHistoryEvent(id: "os", date: now.addingTimeInterval(-3 * 86_400), kind: .os(from: "iOS 17.3", to: "iOS 17.4")),
                DeviceHistoryEvent(id: "install", date: now.addingTimeInterval(-9 * 86_400), kind: .installed(version: "2.4.0")),
            ],
            activity: activity,
            usage: DeviceUsage(counts: usageCounts),
            range: .week,
            medianDuration: 240
        )
    }
}

private let deviceSessionTimeFormatter = DateFormatter(format: "EEE HH:mm")
private let deviceWeekdayFormatter = DateFormatter(format: "EEE")
private let deviceDayFormatter = DateFormatter(format: "d")
private let deviceMonthFormatter = DateFormatter(format: "MMM")
