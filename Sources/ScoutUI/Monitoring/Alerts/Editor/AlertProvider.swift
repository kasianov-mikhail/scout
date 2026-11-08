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
            update(rule) { _ in nil }
        } catch {
            result = .failure(error)
        }
    }

    func mute(_ rule: AlertRule, until: Date) {
        do {
            try registry.remember(.muted(until: until), for: rule)
            update(rule) { status in
                AlertStatus(
                    rule: status.rule,
                    outcome: AlertOutcome(state: .muted(until: until), shouldNotify: false),
                    reading: status.reading
                )
            }
        } catch {
            result = .failure(error)
        }
    }

    private func update(_ rule: AlertRule, _ transform: (AlertStatus) -> AlertStatus?) {
        guard case .success(let statuses)? = result else {
            return
        }
        result = .success(statuses.compactMap { $0.rule == rule ? transform($0) : $0 })
    }

    func fetch(in database: SeriesReader) async throws -> [AlertStatus] {
        try await AlertEngine(registry: registry, notifier: nil).statuses(in: database)
    }
}
