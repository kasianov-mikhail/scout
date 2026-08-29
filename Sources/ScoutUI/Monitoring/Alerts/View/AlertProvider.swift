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

    /// Whether the system currently refuses notifications for the host app, so the
    /// views can say that firing rules won't reach this device.
    @Published private(set) var notificationsOff = false

    private let registry: AlertRegistry
    private let notifier: AlertNotifier?
    private let engine: AlertEngine

    init(_ result: ProviderResult<Output>? = nil, registry: AlertRegistry = AlertRegistry(), notifier: AlertNotifier? = nil) {
        self.registry = registry
        self.notifier = notifier
        self.engine = AlertEngine(registry: registry, notifier: notifier)
        self.result = result
    }

    func add(_ rule: AlertRule) async {
        do {
            let rules = try registry.rules()
            try registry.save(rules + [rule])

            if rules.count == 0, let notifier {
                _ = await notifier.requestAuthorization()
            }

            await refreshNotificationStatus()
        } catch {
            result = .failure(error)
        }
    }

    func refreshNotificationStatus() async {
        guard let notifier else {
            return
        }
        notificationsOff = await notifier.refusesNotifications()
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
        try await engine.statuses(in: database)
    }
}
