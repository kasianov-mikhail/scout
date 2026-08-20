//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor
final class AlertRegistry {
    struct UnreadableStoreError: LocalizedError {
        let key: String
        let underlying: any Error

        var errorDescription: String? {
            "The stored alert data under \"\(key)\" can't be read: \(underlying.localizedDescription)"
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func rules() throws -> [AlertRule] {
        try decode([AlertRule].self, forKey: "scout_alert_rules") ?? []
    }

    func save(_ rules: [AlertRule]) throws {
        let states = try states()
        try encode(rules, forKey: "scout_alert_rules")
        try encode(states.filter { rules.contains($0.key) }, forKey: "scout_alert_states")
    }

    func state(for rule: AlertRule) throws -> AlertState {
        try states()[rule] ?? .armed
    }

    func remember(_ state: AlertState, for rule: AlertRule) throws {
        var updated = try states()
        updated[rule] = state
        try encode(updated, forKey: "scout_alert_states")
    }

    private func states() throws -> [AlertRule: AlertState] {
        try decode([AlertRule: AlertState].self, forKey: "scout_alert_states") ?? [:]
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw UnreadableStoreError(key: key, underlying: error)
        }
    }

    private func encode(_ value: some Encodable, forKey key: String) throws {
        defaults.set(try JSONEncoder().encode(value), forKey: key)
    }
}
