//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class AlertProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[AlertStatus]>?

    @Published private(set) var notificationsDenied = false

    private let registry: AlertRegistry
    private let permission: NotificationPermission?

    init(_ result: ProviderResult<Output>? = nil, registry: AlertRegistry = AlertRegistry(), permission: NotificationPermission? = nil) {
        self.registry = registry
        self.permission = permission
        self.result = result
    }

    func add(_ rule: AlertRule) async {
        do {
            let rules = try registry.rules()

            guard !rules.contains(rule) else { return }

            try registry.save(rules + [rule])

            await permission?.requestIfUndetermined()
            await refreshNotificationStatus()
        } catch {
            result = .failure(error)
        }
    }

    func refreshNotificationStatus() async {
        if let permission {
            notificationsDenied = await permission.isDenied
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

    func fetch(in database: SeriesReader) async throws -> [AlertStatus] {
        try await AlertEngine(registry: registry, notifier: nil).statuses(in: database)
    }
}
