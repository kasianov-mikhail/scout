//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import NativeConnector
@testable import Support

@Suite("ActivitySeries")
struct ActivitySeriesTests {
    @Test("Sliding windows match a brute-force reference over a multi-week dataset")
    func matchesBruteForce() {
        let start = TestDate.reference
        let range = start..<start.addingTimeInterval(42 * .day)

        var visits: [ActivityVisit] = []
        for dayOffset in -35..<42 {
            let day = start.addingTimeInterval(TimeInterval(dayOffset) * .day)
            let activeUsers = (dayOffset * 7 + 3) % 11
            for index in 0...activeUsers {
                let user = "user-\((dayOffset * 5 + index) % 17)"
                visits.append(ActivityVisit(date: day.addingTimeInterval(TimeInterval(index) * .hour), user: user))
            }
        }

        let windowed = ActivityPoint.points(visits: visits, in: range)
        let reference = Self.bruteForce(visits: visits, in: range)

        #expect(windowed.map(Self.tuple) == reference.map(Self.tuple))
        #expect(windowed.count > 0)
    }

    @Test("Points come back ascending without an extra sort")
    func ascending() {
        let start = TestDate.reference
        let range = start..<start.addingTimeInterval(10 * .day)
        let visits = (0..<10).map {
            ActivityVisit(date: start.addingTimeInterval(TimeInterval($0) * .day), user: "user-\($0)")
        }

        let points = ActivityPoint.points(visits: visits, in: range)

        #expect(points.map(\.date) == points.map(\.date).sorted())
    }

    private static func tuple(_ point: ActivityPoint) -> [Int64] {
        [point.date, Int64(point.dau), Int64(point.wau), Int64(point.mau)]
    }

    private static func bruteForce(visits: [ActivityVisit], in range: Range<Date>) -> [ActivityPoint] {
        var users: [Date: Set<String>] = [:]
        for visit in visits {
            users[visit.date.startOfDay, default: []].insert(visit.user)
        }

        func distinctUsers(ending day: Date, days: Int) -> Int {
            var combined: Set<String> = []
            for offset in 0..<days {
                if let active = users[day.addingTimeInterval(-TimeInterval(offset) * .day)] {
                    combined.formUnion(active)
                }
            }
            return combined.count
        }

        var points: [ActivityPoint] = []
        var day = range.lowerBound.startOfDay
        while day < range.upperBound {
            defer { day = day.addingTimeInterval(.day) }
            let dau = users[day]?.count ?? 0
            let wau = distinctUsers(ending: day, days: 7)
            let mau = distinctUsers(ending: day, days: 30)
            guard mau > 0 else { continue }
            points.append(ActivityPoint(date: day.millisecondsSince1970, dau: dau, wau: wau, mau: mau))
        }
        return points.sorted { $0.date < $1.date }
    }
}
