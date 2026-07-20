//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ActivityVisit {
    let date: Date
    let user: String
}

extension ActivityPoint {
    static func points(visits: [ActivityVisit], in range: Range<Date>) -> [ActivityPoint] {
        var users: [Date: Set<String>] = [:]
        for visit in visits {
            users[visit.date.startOfDay, default: []].insert(visit.user)
        }

        let firstDay = range.lowerBound.startOfDay

        var week = UserWindow()
        var month = UserWindow()
        for offset in 1...7 {
            week.insert(users[firstDay.addingTimeInterval(-TimeInterval(offset) * .day)])
        }
        for offset in 1...30 {
            month.insert(users[firstDay.addingTimeInterval(-TimeInterval(offset) * .day)])
        }

        var points: [ActivityPoint] = []
        var day = firstDay

        while day < range.upperBound {
            defer { day = day.addingTimeInterval(.day) }

            week.insert(users[day])
            month.insert(users[day])
            week.remove(users[day.addingTimeInterval(-7 * .day)])
            month.remove(users[day.addingTimeInterval(-30 * .day)])

            let mau = month.count
            guard mau > 0 else { continue }

            let dau = users[day]?.count ?? 0
            points.append(ActivityPoint(date: day.millisecondsSince1970, dau: dau, wau: week.count, mau: mau))
        }
        return points
    }
}

private struct UserWindow {
    private var counts: [String: Int] = [:]

    var count: Int { counts.count }

    mutating func insert(_ users: Set<String>?) {
        guard let users else { return }
        for user in users {
            counts[user, default: 0] += 1
        }
    }

    mutating func remove(_ users: Set<String>?) {
        guard let users else { return }
        for user in users where counts[user] != nil {
            let remaining = counts[user]! - 1
            if remaining > 0 {
                counts[user] = remaining
            } else {
                counts[user] = nil
            }
        }
    }
}
