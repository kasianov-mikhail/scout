//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

typealias MetricReadings = [AlertMetric: MetricReading]

@MainActor
final class AlertEngine {
    private let registry: AlertRegistry
    private let notifier: AlertNotifier?

    init(registry: AlertRegistry, notifier: AlertNotifier?) {
        self.registry = registry
        self.notifier = notifier
    }

    func statuses(in database: SeriesReader) async throws -> [AlertStatus] {
        let now = Date()
        let rules = try registry.rules()
        let readings = try await readings(for: Set(rules.map(\.metric)), in: database)

        return try rules.compactMap { rule in
            guard let reading = readings[rule.metric] else {
                return nil
            }
            let outcome = rule.outcome(
                reading: reading,
                state: try registry.state(for: rule),
                now: now
            )
            return AlertStatus(
                rule: rule,
                outcome: outcome,
                reading: reading,
                notified: try registry.notified(for: rule)
            )
        }
    }

    private func readings(for metrics: Set<AlertMetric>, in database: SeriesReader) async throws -> MetricReadings {
        try await withThrowingTaskGroup(of: (AlertMetric, MetricReading).self) { group in
            for metric in metrics {
                group.addTask {
                    try await (metric, metric.reading(in: database, period: AlertScale.trailing))
                }
            }

            var readings: MetricReadings = [:]
            for try await (metric, reading) in group {
                readings[metric] = reading
            }
            return readings
        }
    }

    @discardableResult
    func run(in database: SeriesReader) async throws -> [AlertStatus] {
        let statuses = try await statuses(in: database)

        for status in statuses {
            try registry.remember(status.outcome.state, for: status.rule)
            if status.isArmed {
                try registry.forgetNotified(for: status.rule)
            }
        }

        if let delivery = await notifier?.deliver(statuses) {
            let deliveredAt = Date()
            for status in delivery.delivered {
                try registry.rememberNotified(deliveredAt, for: status.rule)
            }
            for status in delivery.undelivered {
                try registry.remember(.armed, for: status.rule)
            }
        }

        return statuses
    }
}
