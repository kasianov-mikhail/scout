//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct StatusDistribution: Equatable {
    let breakdowns: [Date: StatusBreakdown]

    init(breakdowns: [Date: StatusBreakdown]) {
        self.breakdowns = breakdowns
    }

    init(series: [MetricSeries]) {
        self.init(breakdowns: StatusBreakdown.buckets(from: series))
    }

    var isEmpty: Bool {
        breakdowns.values.allSatisfy { $0.total == 0 }
    }

    func summary(in range: Range<Date>, bucket: SeriesBucket) -> StatusBreakdown {
        breakdowns
            .filter { bucket.range(startingOn: $0.key).overlaps(range) }
            .values
            .reduce(StatusBreakdown(), +)
    }
}
