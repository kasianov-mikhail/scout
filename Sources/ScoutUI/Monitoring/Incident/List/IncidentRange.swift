//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum IncidentRange: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: Self { self }
}

extension IncidentRange {
    var title: String {
        switch self {
        case .week:
            "7 days"
        case .month:
            "30 days"
        case .year:
            "Year"
        }
    }

    var dayCount: Int {
        switch self {
        case .week:
            7
        case .month:
            30
        case .year:
            365
        }
    }

    func range(now: Date) -> Range<Date> {
        let today = now.startOfDay
        return today.addingDay(1 - dayCount)..<today.addingDay()
    }

    func previousRange(now: Date) -> Range<Date> {
        let current = range(now: now)
        return current.lowerBound.addingDay(-dayCount)..<current.lowerBound
    }

    func slices(now: Date, count: Int = 7) -> [Range<Date>] {
        let window = range(now: now)
        let step = window.upperBound.timeIntervalSince(window.lowerBound) / Double(count)

        guard step > 0 else {
            return []
        }

        return (0..<count).map { index in
            let start = index == 0 ? window.lowerBound : window.lowerBound.addingTimeInterval(step * Double(index))
            let end = index == count - 1 ? window.upperBound : window.lowerBound.addingTimeInterval(step * Double(index + 1))
            return start..<end
        }
    }
}
