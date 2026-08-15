//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package typealias StatusProbe = @Sendable () async -> Backend.Status

package typealias AccountWarning = @Sendable () async throws -> Backend.AccountStatus?

public struct Backend: Sendable {
    package let id: String
    package let database: any Database
    package let checkAvailability: @Sendable () async -> Bool
    package let displayName: String
    package let engine: Engine
    package let probeStatus: StatusProbe?
    package let accountWarning: AccountWarning?

    package init(id: String, database: any Database, checkAvailability: @escaping @Sendable () async -> Bool, displayName: String, engine: Engine, probeStatus: StatusProbe? = nil, accountWarning: AccountWarning? = nil) {
        self.id = id
        self.database = database
        self.checkAvailability = checkAvailability
        self.displayName = displayName
        self.engine = engine
        self.probeStatus = probeStatus
        self.accountWarning = accountWarning
    }
}
