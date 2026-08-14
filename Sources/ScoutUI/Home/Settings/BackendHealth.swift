//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

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

extension Backend.Engine {
    var label: String {
        switch self {
        case .cloudKit:
            "CloudKit"
        case .server:
            "Scout Server"
        case .local:
            "On Device"
        }
    }
}

extension Backend.Status? {
    var healthLabel: String {
        switch self {
        case .reachable:
            "Operational"
        case .readOnly:
            "Read-Only"
        case .unreachable, .failed:
            "Unreachable"
        case nil:
            "Checking"
        }
    }

    var healthColor: Color {
        switch self {
        case .reachable:
            .green
        case .readOnly:
            .orange
        case .unreachable, .failed:
            .red
        case nil:
            .gray
        }
    }

    var healthIcon: String {
        switch self {
        case .reachable:
            "checkmark.circle.fill"
        case .readOnly:
            "exclamationmark.triangle.fill"
        case .unreachable, .failed:
            "xmark.octagon.fill"
        case nil:
            "questionmark.circle.fill"
        }
    }
}

extension BackendHealth {
    var latencyLabel: String {
        latency.map { "\($0) ms" } ?? "—"
    }

    var lastCheckedLabel: String {
        lastChecked?.relativeString ?? "Never"
    }

    var pingSpreadLabel: String? {
        guard let low = pings.min(), let high = pings.max() else {
            return nil
        }
        let average = pings.reduce(0, +) / pings.count
        return "\(low) / \(average) / \(high) ms"
    }
}

extension BackendHealth: Fixture {
    static var samples: [BackendHealth] {
        [
            BackendHealth(
                id: "https://api.scout.app",
                name: "Production",
                engine: .server(
                    .init(endpoint: "api.scout.app", hasAPIKey: true, isSecure: true)
                ),
                status: .reachable,
                latency: 148,
                lastChecked: Date(timeIntervalSinceNow: -12),
                pings: [140, 152, 138, 171, 149, 162, 144, 155, 148, 158, 143, 148],
                probe: {
                    try? await Task.sleep(for: .milliseconds(148))
                    return .reachable
                }
            ),
            BackendHealth(
                id: "iCloud.com.example.scout",
                name: "iCloud",
                engine: .cloudKit,
                status: .reachable,
                latency: 264,
                lastChecked: Date(timeIntervalSinceNow: -47),
                pings: [251, 244, 302, 268, 259, 281, 247, 322, 264, 255, 273, 264],
                probe: {
                    try? await Task.sleep(for: .milliseconds(264))
                    return .reachable
                }
            ),
            BackendHealth(
                id: "https://staging.scout.app",
                name: "Staging",
                engine: .server(
                    .init(endpoint: "staging.scout.app", hasAPIKey: false, isSecure: true)
                )
            ),
            BackendHealth(
                id: "http://localhost:8080",
                name: "Local",
                engine: .server(
                    .init(endpoint: "localhost:8080", hasAPIKey: false, isSecure: false)
                ),
                status: .unreachable,
                lastChecked: Date(timeIntervalSinceNow: -340),
                probe: { .unreachable }
            ),
        ]
    }
}
