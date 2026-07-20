//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricReading {
    init(points: [ChartPoint<Int>], period: some ChartTimeScale) {
        let previous = points.bucket(in: period.previousRange, component: period.pointComponent)
        let current = points.bucket(on: period)

        self.init(
            baseline: previous.map { Double($0.count) }.median ?? 0,
            recent: current.reversed().map { Double($0.count) }
        )
    }

    init(sessions: [ChartPoint<Int>], crashes: [ChartPoint<Int>], period: some ChartTimeScale) {
        let previous = Self.stabilities(
            sessions: sessions, crashes: crashes, in: period.previousRange, component: period.pointComponent)
        let current = Self.stabilities(
            sessions: sessions, crashes: crashes, in: period.initialRange, component: period.pointComponent)

        self.init(baseline: previous.median ?? 0, recent: current)
    }

    static func stabilities(
        sessions: [ChartPoint<Int>], crashes: [ChartPoint<Int>], in range: Range<Date>, component: Calendar.Component
    ) -> [Double] {
        zip(
            sessions.bucket(in: range, component: component).reversed(),
            crashes.bucket(in: range, component: component).reversed()
        )
        .map { Stability(of: $1.count, in: $0.count).value }
    }
}
