//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class AlertProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[AlertStatus]>?

    private let store: AlertStore
    private let notifier: AlertNotifier?
    private let evaluator = AlertEvaluator()

    init(store: AlertStore = AlertStore(), notifier: AlertNotifier? = nil) {
        self.store = store
        self.notifier = notifier
    }

    var rules: [AlertRule] {
        store.rules
    }

    func add(_ rule: AlertRule) async {
        let isFirst = store.rules.count == 0
        store.rules.append(rule)

        if isFirst, let notifier {
            _ = await notifier.requestAuthorization()
        }
    }

    func remove(_ rule: AlertRule) {
        store.rules.removeAll { $0 == rule }
    }

    func fetch(in database: DatabaseReader) async throws -> [AlertStatus] {
        let period = AlertScale.trailing
        let now = Date()

        var statuses: [AlertStatus] = []

        for rule in store.rules {
            let reading = try await rule.metric.reading(in: database, period: period)
            let outcome = evaluator.evaluate(rule, reading: reading, state: store.state(for: rule), now: now)

            store.setState(outcome.state, for: rule)
            statuses.append(AlertStatus(rule: rule, outcome: outcome, reading: reading))
        }

        await notifier?.deliver(statuses)
        return statuses
    }
}
