//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct StatusDistribution: Equatable {
    let breakdowns: [Date: StatusBreakdown]

    init(breakdowns: [Date: StatusBreakdown]) {
        self.breakdowns = breakdowns
    }

    init(series: [MetricSeries]) {
        var breakdowns: [Date: StatusBreakdown] = [:]

        for singleSeries in series {
            guard let category = singleSeries.category else { continue }
            guard let index = StatusBuckets.index(of: category) else { continue }

            for point in singleSeries.points {
                let date = Date(millisecondsSince1970: point.date)
                var breakdown = breakdowns[date, default: StatusBreakdown()]
                breakdown.add(count: Int(point.value.doubleValue), at: index)
                breakdowns[date] = breakdown
            }
        }

        self.breakdowns = breakdowns
    }

    var isEmpty: Bool {
        breakdowns.values.allSatisfy { $0.total == 0 }
    }

    func summary(in range: Range<Date>) -> StatusBreakdown {
        breakdowns
            .filter { range.contains($0.key) }
            .values
            .reduce(StatusBreakdown(), +)
    }
}

extension StatusDistribution {
    static func sample(success: Int, redirect: Int = 0, clientError: Int = 0, serverError: Int = 0) -> StatusDistribution {
        let noon = Calendar.current.startOfDay(for: .now).addingTimeInterval(12 * .hour)
        return StatusDistribution(breakdowns: [
            noon: .sample(success: success, redirect: redirect, clientError: clientError, serverError: serverError)
        ])
    }
}
