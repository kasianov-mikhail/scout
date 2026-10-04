//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package typealias StatusProbe = @Sendable () async -> Backend.Status

public struct Backend: Sendable {
    package let id: String
    package let database: any Database
    package let displayName: String
    package let engine: Engine
    package let probeStatus: StatusProbe?
    package let verifyAccess: (@Sendable () async throws -> Void)?

    package init(id: String, database: any Database, displayName: String, engine: Engine, probeStatus: StatusProbe? = nil, verifyAccess: (@Sendable () async throws -> Void)? = nil) {
        self.id = id
        self.database = database
        self.displayName = displayName
        self.engine = engine
        self.probeStatus = probeStatus
        self.verifyAccess = verifyAccess
    }
}

extension Backend {
    func checkAvailability() async -> Bool {
        guard let verifyAccess else { return true }
        do {
            try await verifyAccess()
            return true
        } catch {
            return false
        }
    }
}
