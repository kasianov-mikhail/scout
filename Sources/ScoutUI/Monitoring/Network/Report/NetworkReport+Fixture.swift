//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension NetworkReport: Fixture {
    static var samples: [NetworkReport] {
        [sample, sample(range: .week), sample(range: .year), sample(day: .now), sample(hour: .now)]
    }

    static var sample: NetworkReport {
        sample(range: .today)
    }

    static func sample(range: NetworkRange, now: Date = .now) -> NetworkReport {
        let starts =
            switch range {
            case .today:
                hours(in: now, now: now)
            case .yesterday:
                hours(in: now.addingDay(-1), now: now)
            case .week:
                days(in: now.startOfDay.addingDay(-6)..<now.startOfDay.addingDay(), now: now)
            case .month:
                days(in: now.startOfDay.addingDay(-29)..<now.startOfDay.addingDay(), now: now)
            case .year:
                months(in: now.startOfMonth.addingMonth(-12)..<now.startOfMonth.addingMonth())
            }

        let days: Double =
            switch range {
            case .today, .yesterday:
                1
            case .week:
                7
            case .month:
                30
            case .year:
                365
            }

        return report(starts: starts, days: days, bucket: range.bucket)
    }

    static func sample(day: Date, now: Date = .now) -> NetworkReport {
        report(starts: hours(in: day, now: now), days: 1, bucket: .hour)
    }

    static func sample(month: Date, now: Date = .now) -> NetworkReport {
        let start = month.startOfMonth
        let starts = days(in: start..<start.addingMonth(), now: now)
        return report(starts: starts, days: Double(starts.count), bucket: .day)
    }

    static func sample(hour: Date) -> NetworkReport {
        report(starts: [hour.startOfHour], days: 0.1, bucket: .hour)
    }
}
