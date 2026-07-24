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

    private let registry: AlertRegistry
    private let notifier: AlertNotifier?
    private let engine: AlertEngine

    init(
        _ result: ProviderResult<Output>? = nil,
        registry: AlertRegistry = AlertRegistry(),
        notifier: AlertNotifier? = nil
    ) {
        self.registry = registry
        self.notifier = notifier
        self.engine = AlertEngine(registry: registry, notifier: notifier)
        self.result = result
    }

    var rules: [AlertRule] {
        registry.rules
    }

    func add(_ rule: AlertRule) async {
        let isFirst = registry.rules.count == 0
        registry.rules.append(rule)

        if isFirst, let notifier {
            _ = await notifier.requestAuthorization()
        }
    }

    func remove(_ rule: AlertRule) {
        registry.rules.removeAll { $0 == rule }
    }

    func fetch(in database: DatabaseReader) async throws -> [AlertStatus] {
        try await engine.statuses(in: database)
    }
}
