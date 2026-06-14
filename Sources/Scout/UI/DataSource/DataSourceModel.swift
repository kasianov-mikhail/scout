//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
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
    let backends: [Backend]

    /// The id of the backend reads currently go to; persisted on change.
    @Published var activeID: String {
        didSet { defaults.set(activeID, forKey: Self.storageKey) }
    }

    /// Reachability per backend id, filled in by ``checkAvailability()``.
    @Published private(set) var statuses: [String: ServerStatus] = [:]

    private let resolved: [ResolvedBackend]
    private let defaults: UserDefaults

    private static let storageKey = "scout_active_backend"

    init(backends: [Backend], defaults: UserDefaults = .standard) {
        self.backends = backends
        self.resolved = backends.map(\.resolved)
        self.defaults = defaults

        let ids = resolved.map(\.id)
        let stored = defaults.string(forKey: Self.storageKey)
        activeID = ids.contains(stored ?? "") ? stored! : (ids.first ?? "")
    }

    /// Whether there is more than one backend to switch between.
    var hasChoice: Bool { backends.count > 1 }

    /// The database reads go to, falling back to the first backend, then to the
    /// sample ``DefaultDatabase`` when there are no backends at all.
    ///
    var activeDatabase: any AppDatabase {
        if let database = resolved.first(where: { $0.id == activeID })?.database ?? resolved.first?.database {
            return database
        }
        return DefaultDatabase()
    }

    /// The CloudKit container of the active backend, if it is a CloudKit one —
    /// used to scope account and schema warnings.
    ///
    var activeContainer: CKContainer? {
        guard let index = resolved.firstIndex(where: { $0.id == activeID }) else { return nil }
        guard case .cloudKit(let container) = backends[index] else {
            return nil
        }
        return container
    }

    /// The backends as pickable options, each carrying its latest status.
    var servers: [ServerOption] {
        backends.indices.map { index in
            ServerOption(
                id: resolved[index].id,
                name: backends[index].displayName,
                host: backends[index].displayHost,
                status: statuses[resolved[index].id] ?? .unknown
            )
        }
    }

    /// Probes every backend concurrently and records whether it is reachable.
    func checkAvailability() async {
        await withTaskGroup(of: (String, ServerStatus).self) { group in
            for backend in resolved {
                group.addTask {
                    do {
                        try await backend.checkAvailability()
                        return (backend.id, .reachable)
                    } catch {
                        return (backend.id, .unreachable)
                    }
                }
            }
            for await (id, status) in group {
                statuses[id] = status
            }
        }
    }
}
