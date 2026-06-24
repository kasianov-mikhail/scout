//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Connection: Identifiable, Sendable {
    let id: String
    let name: String
    let status: Backend.Status
    var probe: @Sendable () async -> Backend.Status = { .unknown }
}

extension Connection {
    init(backend: Backend) {
        self.id = backend.id
        self.name = backend.displayName
        self.status = .unknown
        self.probe = backend.probeStatus
    }

    func refreshingStatus() async -> Connection {
        Connection(id: id, name: name, status: await probe(), probe: probe)
    }
}

@MainActor
extension [Connection] {
    func refreshingStatuses() async -> [Connection] {
        await withTaskGroup(of: (Int, Connection).self) { group in
            for (index, connection) in enumerated() {
                group.addTask {
                    (index, await connection.refreshingStatus())
                }
            }
            var refreshed = self
            for await (index, connection) in group {
                refreshed[index] = connection
            }
            return refreshed
        }
    }
}

extension Connection {
    static var samples: [Connection] {
        [
            Connection(id: "https://api.scout.app", name: "Production", status: .reachable, probe: { .reachable }),
            Connection(id: "https://staging.scout.app", name: "Staging", status: .unknown, probe: { .unknown }),
            Connection(id: "http://localhost:8080", name: "Local", status: .unreachable, probe: { .unreachable }),
        ]
    }
}
