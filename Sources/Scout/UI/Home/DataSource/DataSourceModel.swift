//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// Holds the configured backends and tracks which one the UI reads from.
///
/// Reads go to a single active backend (the "primary"); the user switches
/// between them through ``DataSourceMenu``. The choice is persisted, so it
/// survives relaunches, and each backend's reachability is probed for the
/// status dots. Records are still synced to every backend regardless of the
/// selection — this only governs reads.
///
@MainActor
final class DataSourceModel: ObservableObject {
    private let resolved: [ResolvedBackend]

    /// The id of the backend reads currently go to; persisted on change.
    @Published var activeID: String {
        didSet { defaults.set(activeID, forKey: Self.storageKey) }
    }

    /// Reachability per backend id, filled in by ``refreshStatuses()``.
    @Published private(set) var statuses: [String: BackendStatus] = [:]

    private let defaults: UserDefaults
    private let probe: @Sendable (ResolvedBackend) async -> BackendStatus

    private static let storageKey = "scout_active_backend"

    init(
        backends: [any Backend], defaults: UserDefaults = .standard,
        probe: @escaping @Sendable (ResolvedBackend) async -> BackendStatus = { await $0.probeStatus() }
    ) {
        self.resolved = backends.resolved
        self.defaults = defaults
        self.probe = probe

        let ids = resolved.map(\.id)
        let stored = defaults.string(forKey: Self.storageKey)
        activeID = ids.contains(stored ?? "") ? stored! : (ids.first ?? "")
    }

    /// Whether there is more than one backend to switch between.
    var hasChoice: Bool { resolved.count > 1 }

    /// The database reads go to, falling back to the first backend, then to the
    /// sample ``DefaultDatabase`` when there are no backends at all.
    ///
    var activeDatabase: any AppDatabase {
        if let database = resolved.first(where: { $0.id == activeID })?.database ?? resolved.first?.database {
            return database
        }
        return DefaultDatabase()
    }

    /// The resolved active backend, used to scope account and schema warnings.
    var activeBackend: ResolvedBackend? {
        resolved.first { $0.id == activeID }
    }

    /// The backends as pickable options, each carrying its latest status.
    var servers: [BackendOption] {
        resolved.map { backend in
            BackendOption(
                id: backend.id,
                name: backend.displayName,
                host: backend.displayHost,
                status: statuses[backend.id] ?? .unknown
            )
        }
    }

    /// Probes every backend concurrently and records its reachability for the
    /// status dots.
    ///
    func refreshStatuses() async {
        await withTaskGroup(of: (String, BackendStatus).self) { group in
            for backend in resolved {
                group.addTask { [probe] in
                    (backend.id, await probe(backend))
                }
            }
            for await (id, status) in group {
                statuses[id] = status
            }
        }
    }
}
