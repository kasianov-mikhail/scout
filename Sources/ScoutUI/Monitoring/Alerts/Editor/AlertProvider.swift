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
    struct DuplicateRuleError: LocalizedError {
        var errorDescription: String? {
            "An identical rule already exists"
        }
    }

    @Published var result: ProviderResult<[AlertStatus]>?

    @Published private(set) var notificationsDenied = false

    private let registry: AlertRegistry
    private let permission: NotificationPermission?

    init(_ result: ProviderResult<Output>? = nil, registry: AlertRegistry = AlertRegistry(), permission: NotificationPermission? = nil) {
        self.registry = registry
        self.permission = permission
        self.result = result
    }

    func add(_ rule: AlertRule) async throws {
        let rules = try registry.rules()

        guard !rules.contains(rule) else {
            throw DuplicateRuleError()
        }

        try registry.save(rules + [rule])

        await permission?.requestIfUndetermined()
        await refreshNotificationStatus()
    }

    func update(rule: AlertRule, updated: AlertRule) async throws {
        var rules = try registry.rules()

        guard let index = rules.firstIndex(of: rule) else {
            return
        }
        if updated == rule {
            return
        }
        guard !rules.contains(updated) else {
            throw DuplicateRuleError()
        }

        let state: AlertState
        if rule.metric == updated.metric {
            state = try registry.state(for: rule)
        } else {
            state = .armed
        }
        rules[index] = updated
        try registry.save(rules)
        try registry.remember(state, for: updated)

        if updated.notifies {
            await permission?.requestIfUndetermined()
        }
        await refreshNotificationStatus()
    }

    func mute(_ rule: AlertRule, hours: Int) throws {
        try registry.remember(.muted(until: Date().adding(.hour, value: hours)), for: rule)
    }

    func unmute(_ rule: AlertRule) throws {
        try registry.remember(.armed, for: rule)
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
