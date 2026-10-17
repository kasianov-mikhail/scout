//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct StabilityPoints {
    let sessions: [ChartPoint<Int>]
    let crashes: [ChartPoint<Int>]

    func values(range: Range<Date>, component: Calendar.Component) -> [Double] {
        zip(
            sessions.bucket(in: range, component: component).reversed(),
            crashes.bucket(in: range, component: component).reversed()
        )
        .map { Stability(of: $1.value, in: $0.value).value }
    }
}

extension StabilityPoints {
    init(database: SeriesReader, range: Range<Date>) async throws {
        async let sessions = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: SessionEntry.recordType, bucket: .hour, range: range)
        )
        async let crashes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: CrashEntry.recordType, bucket: .hour, range: range)
        )

        self.sessions = try await sessions.flatMap { $0.chartPoints() }
        self.crashes = try await crashes.flatMap { $0.chartPoints() }
    }
}
