//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

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

        var statuses: [AlertStatus] = []
        for rule in registry.rules {
            let reading = try await rule.metric.reading(in: database, period: AlertScale.trailing)
            let outcome = evaluator.evaluate(rule, reading: reading, state: registry.state(for: rule), now: now)
            statuses.append(AlertStatus(rule: rule, outcome: outcome, reading: reading))
        }
        return statuses
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
