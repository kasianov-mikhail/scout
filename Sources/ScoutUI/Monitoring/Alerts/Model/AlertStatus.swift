//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertStatus: Equatable {
    let rule: AlertRule
    let outcome: AlertOutcome
    let reading: MetricReading
}

extension AlertStatus {
    var detail: String? {
        guard let current = reading.recent.last else { return nil }
        return "\(rule.metric.format(current)) — \(rule.condition.summary(format: rule.metric.format))"
    }

    var series: MiniChartSeries {
        MiniChartSeries(values: reading.recent.map { Int($0 * 1000) })
    }
}

extension [AlertStatus] {
    var firingCount: Int {
        count { if case .firing = $0.outcome.state { true } else { false } }
    }

    var allHealthy: Bool {
        count > 0 && allSatisfy { $0.outcome.state == .armed }
    }
}
