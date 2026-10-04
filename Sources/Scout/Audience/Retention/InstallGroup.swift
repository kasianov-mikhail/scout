//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct InstallGroup {
    let installs: [DatedID]

    init(_ installs: [DatedID]) {
        self.installs = installs
    }

    var count: Int {
        installs.count
    }

    var byWeek: [Date: InstallGroup] {
        Dictionary(
            grouping: installs,
            by: \.date.startOfWeek
        )
        .mapValues(InstallGroup.init)
    }

    func days(in range: Range<Date>) -> InstallGroup {
        InstallGroup(installs.filter { range.contains($0.date) }.map(\.startOfDay))
    }

    func retention(week: Date, sessionDays: [InstallDates], now: Date) -> [Double?] {
        let days = installs.map {
            (day: $0.date, active: sessionDays.dates(of: $0.id))
        }

        return RetentionCohort.dayOffsets.map { offset in
            guard week.addingDay(7 + offset) < now else {
                return nil
            }
            let share = days.count {
                $0.active.contains($0.day.addingDay(offset))
            }
            return Double(share) / Double(count)
        }
    }

    func affected(by dates: [InstallDates], within horizon: Int) -> Int {
        installs.count {
            dates.dates(of: $0.id)
                .contains(where: ($0.date..<$0.date.addingDay(horizon)).contains)
        }
    }

    func grouped(by names: [String: String]) -> [String: InstallGroup] {
        installs.reduce(into: [String: [DatedID]]()) { groups, install in
            if let name = names[install.id] {
                groups[name, default: []].append(install)
            }
        }
        .mapValues(InstallGroup.init)
    }
}
