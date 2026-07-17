//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package typealias AccountWarning = @Sendable () async throws -> Backend.AccountStatus?

public struct Backend: Sendable {
    package let id: String
    package let database: any Database
    package let checkAvailability: @Sendable () async -> Bool
    package let displayName: String

    package var serverInfo: ServerInfo? = nil
    package var probeStatus: @Sendable () async -> Status = { .unknown }
    package var accountWarning: AccountWarning = { nil }
    package var onSetup: @MainActor @Sendable () -> Void = {}

    package init(
        id: String,
        database: any Database,
        checkAvailability: @escaping @Sendable () async -> Bool,
        displayName: String,
        serverInfo: ServerInfo? = nil,
        probeStatus: @escaping @Sendable () async -> Status = { .unknown },
        accountWarning: @escaping AccountWarning = { nil },
        onSetup: @escaping @MainActor @Sendable () -> Void = {}
    ) {
        self.id = id
        self.database = database
        self.checkAvailability = checkAvailability
        self.displayName = displayName
        self.serverInfo = serverInfo
        self.probeStatus = probeStatus
        self.accountWarning = accountWarning
        self.onSetup = onSetup
    }

    package enum Status: Sendable {
        case reachable
        case readOnly
        case unreachable
        case failed(any Error & Sendable)
        case unknown
    }

    package enum AccountStatus: Sendable {
        case noAccount
        case restricted
        case couldNotDetermine
        case temporarilyUnavailable
    }

    package struct ServerInfo: Sendable {
        package let endpoint: String
        package let hasAPIKey: Bool
        package let isSecure: Bool

        package init(endpoint: String, hasAPIKey: Bool, isSecure: Bool) {
            self.endpoint = endpoint
            self.hasAPIKey = hasAPIKey
            self.isSecure = isSecure
        }
    }
}

extension Backend.Status: Equatable {
    static package func == (lhs: Self, rhs: Self) -> Bool {
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
