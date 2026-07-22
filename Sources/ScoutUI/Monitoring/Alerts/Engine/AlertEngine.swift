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
    private let evaluator = AlertEvaluator()

    init(registry: AlertRegistry, notifier: AlertNotifier?) {
        self.registry = registry
        self.notifier = notifier
    }

    func statuses(in database: DatabaseReader) async throws -> [AlertStatus] {
        let now = Date()
        let readings = try await readings(for: Set(registry.rules.map(\.metric)), in: database)

        return registry.rules.compactMap { rule in
            guard let reading = readings[rule.metric] else {
                return nil
            }
            let outcome = evaluator.evaluate(
                rule,
                reading: reading,
                state: registry.state(for: rule),
                now: now
            )
            return AlertStatus(rule: rule, outcome: outcome, reading: reading)
        }
    }

    private func readings(for metrics: Set<AlertMetric>, in database: DatabaseReader) async throws -> MetricReadings {
        try await withThrowingTaskGroup(of: (AlertMetric, MetricReading).self) { group in
            for metric in metrics {
                group.addTask {
                    (metric, try await metric.reading(in: database, period: AlertScale.trailing))
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
    func run(in database: DatabaseReader) async throws -> [AlertStatus] {
        let statuses = try await statuses(in: database)

        for status in statuses {
            registry.remember(status.outcome.state, for: status.rule)
        }

        await notifier?.deliver(statuses)
        return statuses
    }
}
