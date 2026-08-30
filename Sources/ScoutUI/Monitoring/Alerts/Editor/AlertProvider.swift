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

    @Published private(set) var notificationsDenied = false

    private let registry: AlertRegistry
    private let notifier: AlertNotifier?

    init(_ result: ProviderResult<Output>? = nil, registry: AlertRegistry = AlertRegistry(), notifier: AlertNotifier? = nil) {
        self.registry = registry
        self.notifier = notifier
        self.result = result
    }

    func add(_ rule: AlertRule) async {
        do {
            let rules = try registry.rules()

            guard !rules.contains(rule) else { return }

            try registry.save(rules + [rule])

            if let notifier, await notifier.needsAuthorization() {
                await notifier.requestAuthorization()
                await refreshNotificationStatus()
            }
        } catch {
            result = .failure(error)
        }
    }

    func refreshNotificationStatus() async {
        if let notifier {
            notificationsDenied = await notifier.refusesNotifications()
        }
    }

    func remove(_ rule: AlertRule) {
        do {
            var rules = try registry.rules()
            rules.removeAll { $0 == rule }
            try registry.save(rules)
        } catch {
            result = .failure(error)
        }
    }

    func fetch(in database: DatabaseReader) async throws -> [AlertStatus] {
        try await AlertEngine(registry: registry, notifier: notifier).statuses(in: database)
    }
}
