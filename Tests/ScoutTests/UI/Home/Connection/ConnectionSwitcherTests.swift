//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("ConnectionSwitcher")
struct ConnectionSwitcherTests {
    let primary = URL(string: "https://a.scout.app")!
    let secondary = URL(string: "https://b.scout.app")!

    var backends: [Backend] {
        [.server(url: primary), .server(url: secondary)]
    }

    @Test("Defaults to the first backend")
    func defaultsToFirst() {
        let model = ConnectionSwitcher(backends: backends, defaults: makeDefaults())
        #expect(model.activeID == primary.absoluteString)
    }

    @Test("Restores a persisted selection across instances")
    func restoresSelection() {
        let defaults = makeDefaults()
        let first = ConnectionSwitcher(backends: backends, defaults: defaults)
        first.activeID = secondary.absoluteString

        let second = ConnectionSwitcher(backends: backends, defaults: defaults)
        #expect(second.activeID == secondary.absoluteString)
    }

    @Test("Falls back to the first backend when the stored one is gone")
    func ignoresStaleSelection() {
        let defaults = makeDefaults()
        defaults.set("https://gone.scout.app", forKey: "scout_active_backend")

        let model = ConnectionSwitcher(backends: backends, defaults: defaults)
        #expect(model.activeID == primary.absoluteString)
    }

    @Test("Maps backends to options with unknown status by default")
    func mapsConnections() {
        let model = ConnectionSwitcher(backends: backends, defaults: makeDefaults())
        let connections = model.options

        #expect(connections.count == 2)
        #expect(connections[0].id == primary.absoluteString)
        #expect(connections[0].name == "a.scout.app")
        #expect(connections.allSatisfy { $0.status == .unknown })
    }

    @Test("A choice exists only with more than one backend")
    func hasChoice() {
        #expect(ConnectionSwitcher(backends: backends, defaults: makeDefaults()).hasChoice)
        #expect(!ConnectionSwitcher(backends: [.server(url: primary)], defaults: makeDefaults()).hasChoice)
    }

    @Test("Refresh records each backend's probed status by id")
    func refreshRecordsProbedStatus() async {
        let model = ConnectionSwitcher(
            backends: backends,
            defaults: makeDefaults(),
            probe: { $0.displayName == "a.scout.app" ? .reachable : .unreachable }
        )
        await model.refreshStatuses()

        let connections = model.options
        #expect(connections.first { $0.id == primary.absoluteString }?.status == .reachable)
        #expect(connections.first { $0.id == secondary.absoluteString }?.status == .unreachable)
    }

    // MARK: - Factories

    private func makeDefaults() -> UserDefaults {
        let suite = "data-source-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }
}
