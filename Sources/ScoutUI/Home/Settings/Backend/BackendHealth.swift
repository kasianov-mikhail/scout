//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import SwiftUI

struct BackendHealth: Identifiable {
    static let maxPingHistory = 12

    let id: String
    let name: String
    let engine: Backend.Engine
    var status: Backend.Status?
    var latency: Int? = nil
    var lastChecked: Date? = nil
    var pings: [Int] = []
    var probe: StatusProbe?
}

extension BackendHealth {
    init(backend: Backend) {
        self.init(
            id: backend.id,
            name: backend.displayName,
            engine: backend.engine,
            probe: backend.probeStatus
        )
    }

    var endpoint: String {
        guard case let .server(info) = engine else {
            return id
        }
        return info.endpoint
    }

    func recording(status: Backend.Status, latency: Int?, at date: Date) -> BackendHealth {
        var health = self
        health.status = status
        health.latency = latency
        health.lastChecked = date
        if let latency {
            health.pings.append(latency)
            health.pings = Array(health.pings.suffix(Self.maxPingHistory))
        }
        return health
    }
}
