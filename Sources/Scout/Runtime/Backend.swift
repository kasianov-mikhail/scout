//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct Backend: Sendable {
    package let id: String
    package let database: any Database
    package let checkAvailability: @Sendable () async -> Bool
    package let displayName: String
    package let engine: Engine
    package let probeStatus: @Sendable () async -> Status
    package let accountWarning: AccountWarning
    package let isTransientError: @Sendable (any Error) -> Bool

    package init(
        id: String,
        database: any Database,
        checkAvailability: @escaping @Sendable () async -> Bool,
        displayName: String,
        engine: Engine,
        probeStatus: @escaping @Sendable () async -> Status = { .unknown },
        accountWarning: @escaping AccountWarning = { nil },
        isTransientError: @escaping @Sendable (any Error) -> Bool = { _ in false }
    ) {
        self.id = id
        self.database = database
        self.checkAvailability = checkAvailability
        self.displayName = displayName
        self.engine = engine
        self.probeStatus = probeStatus
        self.accountWarning = accountWarning
        self.isTransientError = isTransientError
    }
}

package typealias AccountWarning = @Sendable () async throws -> Backend.AccountStatus?

extension Backend {
    package enum Engine: Sendable {
        case cloudKit
        case server(ServerInfo)
        case local
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
