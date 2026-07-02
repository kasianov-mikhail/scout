//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct BackendHealth: Identifiable {
    let id: String
    let name: String
    let endpoint: String
    let engine: Engine
    var hasAPIKey = false
    var isSecure = true
    var status: Backend.Status = .unknown
    var latency: Int? = nil
    var lastChecked: Date? = nil
    var pings: [Int] = []
    var probe: @Sendable () async -> Backend.Status = { .unknown }
    var schemaChecks: @Sendable () async -> [SchemaCheck] = { [] }
    var runBenchmark: (@Sendable () async -> Bool)? = nil

    enum Engine {
        case cloudKit
        case server
    }
}

extension BackendHealth {
    init(backend: Backend) {
        if let database = backend.database as? HTTPDatabase {
            self.init(
                id: backend.id,
                name: backend.displayName,
                endpoint: database.url.hostWithPort ?? database.url.absoluteString,
                engine: .server,
                hasAPIKey: database.apiKey != nil,
                isSecure: database.url.scheme?.lowercased() == "https",
                probe: backend.probeStatus,
                schemaChecks: backend.schemaChecks,
                runBenchmark: backend.runBenchmark
            )
        } else {
            self.init(
                id: backend.id,
                name: backend.displayName,
                endpoint: backend.id,
                engine: .cloudKit,
                probe: backend.probeStatus,
                schemaChecks: backend.schemaChecks,
                runBenchmark: backend.runBenchmark
            )
        }
    }

    func recording(status: Backend.Status, latency: Int?, at date: Date) -> BackendHealth {
        var health = self
        health.status = status
        health.latency = latency
        health.lastChecked = date
        if let latency {
            health.pings.append(latency)
            if health.pings.count > 12 {
                health.pings.removeFirst(health.pings.count - 12)
            }
        }
        return health
    }
}

extension URL {
    fileprivate var hostWithPort: String? {
        guard let host else { return nil }
        return port.map { "\(host):\($0)" } ?? host
    }
}

extension BackendHealth.Engine {
    var label: String {
        switch self {
        case .cloudKit: "CloudKit"
        case .server: "Scout Server"
        }
    }

    var icon: String {
        switch self {
        case .cloudKit: "icloud"
        case .server: "server.rack"
        }
    }
}

extension Backend.Status {
    var healthLabel: String {
        switch self {
        case .reachable: "Operational"
        case .unreachable: "Unreachable"
        case .unknown: "Checking"
        }
    }

    var healthColor: Color {
        switch self {
        case .reachable: .green
        case .unreachable: .red
        case .unknown: .gray
        }
    }

    var healthIcon: String {
        switch self {
        case .reachable: "checkmark.circle.fill"
        case .unreachable: "xmark.octagon.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }
}

extension BackendHealth {
    var latencyLabel: String {
        latency.map { "\($0) ms" } ?? "—"
    }

    var lastCheckedLabel: String {
        lastChecked?.agoLabel ?? "Never"
    }

    var pingSpreadLabel: String? {
        guard let low = pings.min(), let high = pings.max(), pings.count > 0 else { return nil }
        let average = pings.reduce(0, +) / pings.count
        return "\(low) / \(average) / \(high) ms"
    }
}

extension Date {
    var agoLabel: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension BackendHealth {
    static var samples: [BackendHealth] {
        [
            BackendHealth(
                id: "https://api.scout.app",
                name: "Production",
                endpoint: "api.scout.app",
                engine: .server,
                hasAPIKey: true,
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
                endpoint: "iCloud.com.example.scout",
                engine: .cloudKit,
                status: .reachable,
                latency: 264,
                lastChecked: Date(timeIntervalSinceNow: -47),
                pings: [251, 244, 302, 268, 259, 281, 247, 322, 264, 255, 273, 264],
                probe: {
                    try? await Task.sleep(for: .milliseconds(264))
                    return .reachable
                },
                schemaChecks: { SchemaCheck.samples },
                runBenchmark: { true }
            ),
            BackendHealth(
                id: "https://staging.scout.app",
                name: "Staging",
                endpoint: "staging.scout.app",
                engine: .server,
                status: .unknown,
                probe: { .unknown }
            ),
            BackendHealth(
                id: "http://localhost:8080",
                name: "Local",
                endpoint: "localhost:8080",
                engine: .server,
                isSecure: false,
                status: .unreachable,
                lastChecked: Date(timeIntervalSinceNow: -340),
                probe: { .unreachable }
            ),
        ]
    }
}

extension SchemaCheck {
    static var samples: [SchemaCheck] {
        [
            SchemaCheck(recordType: "Event", isValid: true),
            SchemaCheck(recordType: "Session", isValid: true),
            SchemaCheck(recordType: "Launch", isValid: true),
            SchemaCheck(recordType: "Version", isValid: true),
            SchemaCheck(recordType: "Install", isValid: true),
            SchemaCheck(recordType: "Device", isValid: true),
            SchemaCheck(recordType: "Crash", isValid: true),
            SchemaCheck(recordType: "IntMetric", isValid: true),
            SchemaCheck(recordType: "DoubleMetric", isValid: true),
            SchemaCheck(recordType: "DateIntMatrix", isValid: false),
        ]
    }
}
