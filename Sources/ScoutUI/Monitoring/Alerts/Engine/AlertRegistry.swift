//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor
final class AlertRegistry {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var rules: [AlertRule] {
        get {
            decode([AlertRule].self, forKey: "scout_alert_rules") ?? []
        }
        set {
            encode(newValue, forKey: "scout_alert_rules")
            states = states.filter { newValue.contains($0.key) }
        }
    }

    func state(for rule: AlertRule) -> AlertState {
        states[rule] ?? .armed
    }

    func remember(_ state: AlertState, for rule: AlertRule) {
        var updated = states
        updated[rule] = state
        states = updated
    }

    private var states: [AlertRule: AlertState] {
        get { decode([AlertRule: AlertState].self, forKey: "scout_alert_states") ?? [:] }
        set { encode(newValue, forKey: "scout_alert_states") }
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }

    private func encode(_ value: some Encodable, forKey key: String) {
        defaults.set(try? JSONEncoder().encode(value), forKey: key)
    }
}
