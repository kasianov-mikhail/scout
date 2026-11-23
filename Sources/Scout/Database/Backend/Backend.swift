//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package typealias StatusProbe = @Sendable () async -> Backend.Status
package typealias AccessCheck = @Sendable () async throws -> Void

package protocol EventUpdatesSource: Sendable {
    func changes() async -> AsyncStream<Void>
    func invalidate() async
}

public struct Backend: Sendable {
    package let id: String
    package var database: any Database
    package let displayName: String
    package let engine: Engine
    package let checkAccess: AccessCheck?
    package let eventUpdates: (any EventUpdatesSource)?
    private let probeAccess: AccessCheck?

    package init(id: String, database: any Database, displayName: String, engine: Engine, checkAccess: AccessCheck? = nil, probeAccess: AccessCheck? = nil, eventUpdates: (any EventUpdatesSource)? = nil) {
        self.id = id
        self.database = database
        self.displayName = displayName
        self.engine = engine
        self.checkAccess = checkAccess
        self.probeAccess = probeAccess ?? checkAccess
        self.eventUpdates = eventUpdates
    }
}

extension Backend {
    package var probeStatus: StatusProbe? {
        guard let probeAccess else {
            return nil
        }
        return {
            do {
                try await probeAccess()
                return .reachable
            } catch {
                return AccountError(error).status
            }
        }
    }
}

extension Backend {
    package enum Status: Sendable, Equatable {
        case reachable
        case readOnly
        case unreachable
    }
}
