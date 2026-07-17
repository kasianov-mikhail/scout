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

        var points: [ActivityPoint] = []
        var day = range.lowerBound.startOfDay

        while day < range.upperBound {
            defer { day = day.addingTimeInterval(.day) }

            let dau = users[day]?.count ?? 0
            let wau = distinctUsers(in: users, ending: day, days: 7)
            let mau = distinctUsers(in: users, ending: day, days: 30)

            guard mau > 0 else { continue }
            points.append(ActivityPoint(date: day.millisecondsSince1970, dau: dau, wau: wau, mau: mau))
        }
        return points.sorted { $0.date < $1.date }
    }

    private static func distinctUsers(in users: [Date: Set<String>], ending day: Date, days: Int) -> Int {
        var combined: Set<String> = []
        for offset in 0..<days {
            if let active = users[day.addingTimeInterval(-TimeInterval(offset) * .day)] {
                combined.formUnion(active)
            }
        }
        return combined.count
    }
}
