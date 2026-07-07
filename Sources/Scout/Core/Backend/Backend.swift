//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation

typealias AccountWarning = @Sendable () async throws -> CKAccountStatus?

public struct Backend: Sendable {
    let id: String
    let database: any Database
    let checkAvailability: @Sendable () async -> Bool
    let displayName: String

    var serverInfo: ServerInfo? = nil
    var probeStatus: @Sendable () async -> Status = { .unknown }
    var accountWarning: AccountWarning = { nil }
    var runBenchmark: (@Sendable () async -> Bool)? = nil
    var onSetup: @MainActor @Sendable () -> Void = {}

    enum Status: CaseIterable, Identifiable, Sendable {
        case reachable
        case unreachable
        case unknown

        var id: Self { self }
    }

    struct ServerInfo: Sendable {
        let endpoint: String
        let hasAPIKey: Bool
        let isSecure: Bool
    }
}

extension Backend {
    static var samples: [Backend] {
        [
            Backend(
                id: "https://api.scout.app",
                database: DefaultDatabase(),
                checkAvailability: { true },
                displayName: "Production",
                probeStatus: { .reachable }
            ),
            Backend(
                id: "https://staging.scout.app",
                database: DefaultDatabase(),
                checkAvailability: { true },
                displayName: "Staging",
                probeStatus: { .unknown }
            ),
            Backend(
                id: "http://localhost:8080",
                database: DefaultDatabase(),
                checkAvailability: { false },
                displayName: "Local",
                probeStatus: { .unreachable }
            ),
        ]
    }
}
