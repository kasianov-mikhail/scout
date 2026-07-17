//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public typealias AccountWarning = @Sendable () async throws -> Backend.AccountStatus?

public struct Backend: Sendable {
    public let id: String
    public let database: any Database
    public let checkAvailability: @Sendable () async -> Bool
    public let displayName: String

    public var serverInfo: ServerInfo? = nil
    public var probeStatus: @Sendable () async -> Status = { .unknown }
    public var accountWarning: AccountWarning = { nil }
    public var onSetup: @MainActor @Sendable () -> Void = {}

    public init(
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

    public enum Status: Sendable {
        case reachable
        case readOnly
        case unreachable
        case failed(any Error & Sendable)
        case unknown
    }

    public enum AccountStatus: Sendable {
        case noAccount
        case restricted
        case couldNotDetermine
        case temporarilyUnavailable
    }

    public struct ServerInfo: Sendable {
        public let endpoint: String
        public let hasAPIKey: Bool
        public let isSecure: Bool

        public init(endpoint: String, hasAPIKey: Bool, isSecure: Bool) {
            self.endpoint = endpoint
            self.hasAPIKey = hasAPIKey
            self.isSecure = isSecure
        }
    }
}

extension Backend.Status: Equatable {
    static public func == (lhs: Self, rhs: Self) -> Bool {
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
