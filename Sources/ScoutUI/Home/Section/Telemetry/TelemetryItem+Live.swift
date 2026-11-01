//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension [TelemetryItem] {
    init(report: [LogCategory: Trend], resources: [ReleaseHealth]) {
        let groups = Set(resources.flatMap { $0.resources.counts.keys }).count

        self = [
            TelemetryItem(kind: .events, value: report[.events]?.count ?? 0, caption: Self.previousCaption(report[.events])),
            TelemetryItem(kind: .crashes, value: report[.crashes]?.count ?? 0, caption: "in period"),
            TelemetryItem(kind: .metrics, value: report[.metrics]?.count ?? 0, caption: "kinds"),
            TelemetryItem(kind: .hangs, value: report[.hangs]?.count ?? 0, caption: "in period"),
            TelemetryItem(kind: .network, value: report[.network]?.count ?? 0, caption: "requests"),
            TelemetryItem(kind: .resources, value: groups, caption: "groups"),
        ]
    }

    private static func previousCaption(_ trend: Trend?) -> String {
        guard let previous = trend?.previous else {
            return "in period"
        }
        return "\(previous) yesterday"
    }
}
