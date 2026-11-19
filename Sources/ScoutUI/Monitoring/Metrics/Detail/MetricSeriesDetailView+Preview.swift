//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

#Preview("Counter") {
    NavigationStack {
        MetricSeriesDetailView<Int>(
            name: "checkout.completed",
            telemetry: .counter,
            range: .constant(.today),
            result: .success([
                MetricSeries(
                    name: "checkout.completed",
                    category: Telemetry.Export.counter.rawValue,
                    points: (0..<24).map { hour in
                        MetricSeriesPoint(
                            date: Date().startOfDay.addingTimeInterval(TimeInterval(hour) * .hour),
                            value: Double(40 + hour * 6)
                        )
                    }
                )
            ]),
            resetDates: .success([Date().startOfDay.addingTimeInterval(13 * .hour)])
        )
        .monospacedNavigationTitle(en: "checkout.completed")
    }
}

#Preview("Gauge") {
    NavigationStack {
        MetricSeriesDetailView<Double>(
            name: "queue_depth",
            telemetry: .meter,
            range: .constant(.today),
            result: .success([
                MetricSeries(
                    name: "queue_depth",
                    category: Telemetry.Export.meter.rawValue,
                    points: (0..<24).map { hour in
                        MetricSeriesPoint(
                            date: Date().startOfDay.addingTimeInterval(TimeInterval(hour) * .hour),
                            value: Double(10 + (hour * 7) % 40)
                        )
                    }
                )
            ])
        )
        .monospacedNavigationTitle(en: "queue_depth")
    }
}
