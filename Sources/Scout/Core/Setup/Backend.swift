//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

typealias AccountWarning = @Sendable () async throws -> Backend.AccountStatus?

public struct Backend: Sendable {
    package let id: String
    package let database: any Database
    let checkAvailability: @Sendable () async -> Bool
    let displayName: String

    var serverInfo: ServerInfo? = nil
    var probeStatus: @Sendable () async -> Status = { .unknown }
    var accountWarning: AccountWarning = { nil }
    var onSetup: @MainActor @Sendable () -> Void = {}

    enum Status: Sendable {
        case reachable
        case readOnly
        case unreachable
        case failed(any Error & Sendable)
        case unknown
    }

    enum AccountStatus: Sendable {
        case noAccount
        case restricted
        case couldNotDetermine
        case temporarilyUnavailable
    }

    struct ServerInfo: Sendable {
        let endpoint: String
        let hasAPIKey: Bool
        let isSecure: Bool
    }
}

extension Backend.Status: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.reachable, .reachable), (.readOnly, .readOnly), (.unreachable, .unreachable), (.unknown, .unknown):
            true
        case let (.failed(lhsError), .failed(rhsError)):
            lhsError as NSError == rhsError as NSError
        default:
            false
        }
    }
}

extension Backend: Fixture {
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
