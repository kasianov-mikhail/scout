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
@Suite("DataSourceModel")
struct DataSourceModelTests {
    let primary = URL(string: "https://a.scout.app")!
    let secondary = URL(string: "https://b.scout.app")!

    var backends: [any Backend] {
        [HostedBackend(url: primary), HostedBackend(url: secondary)]
    }

    @Test("Defaults to the first backend")
    func defaultsToFirst() {
        let model = DataSourceModel(backends: backends, defaults: makeDefaults())
        #expect(model.activeID == primary.absoluteString)
    }

    @Test("Restores a persisted selection across instances")
    func restoresSelection() {
        let defaults = makeDefaults()
        let first = DataSourceModel(backends: backends, defaults: defaults)
        first.activeID = secondary.absoluteString

        let second = DataSourceModel(backends: backends, defaults: defaults)
        #expect(second.activeID == secondary.absoluteString)
    }

    @Test("Falls back to the first backend when the stored one is gone")
    func ignoresStaleSelection() {
        let defaults = makeDefaults()
        defaults.set("https://gone.scout.app", forKey: "scout_active_backend")

        let model = DataSourceModel(backends: backends, defaults: defaults)
        #expect(model.activeID == primary.absoluteString)
    }

    @Test("Maps backends to options with unknown status by default")
    func mapsServers() {
        let model = DataSourceModel(backends: backends, defaults: makeDefaults())
        let servers = model.servers

        #expect(servers.count == 2)
        #expect(servers[0].id == primary.absoluteString)
        #expect(servers[0].name == "a.scout.app")
        #expect(servers[0].host == primary.absoluteString)
        #expect(servers.allSatisfy { $0.status == .unknown })
    }

    @Test("A choice exists only with more than one backend")
    func hasChoice() {
        #expect(DataSourceModel(backends: backends, defaults: makeDefaults()).hasChoice)
        #expect(!DataSourceModel(backends: [HostedBackend(url: primary)], defaults: makeDefaults()).hasChoice)
    }

    @Test("Refresh records each backend's probed status by id")
    func refreshRecordsProbedStatus() async {
        let model = DataSourceModel(
            backends: backends,
            defaults: makeDefaults(),
            probe: { $0.displayName == "a.scout.app" ? .reachable : .unreachable }
        )
        await model.refreshStatuses()

        let servers = model.servers
        #expect(servers.first { $0.id == primary.absoluteString }?.status == .reachable)
        #expect(servers.first { $0.id == secondary.absoluteString }?.status == .unreachable)
    }

    // MARK: - Factories

    private func makeDefaults() -> UserDefaults {
        let suite = "data-source-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }
}
