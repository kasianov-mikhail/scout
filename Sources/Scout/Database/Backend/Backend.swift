//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package typealias StatusProbe = @Sendable () async -> Backend.Status
package typealias AccessCheck = @Sendable () async throws(Backend.AccountError) -> Void

package protocol CacheClearing: Actor {
    var size: Int64 { get }
    func removeAll()
}

public struct Backend: Sendable {
    package let id: String
    package var database: any Database
    package let displayName: String
    package let engine: Engine
    package let checkAccess: AccessCheck?
    package var cache: (any CacheClearing)?

    package init(id: String, database: any Database, displayName: String, engine: Engine, checkAccess: AccessCheck? = nil, cache: (any CacheClearing)? = nil) {
        self.id = id
        self.database = database
        self.displayName = displayName
        self.engine = engine
        self.checkAccess = checkAccess
        self.cache = cache
    }
}

extension Backend {
    package var probeStatus: StatusProbe? {
        guard let checkAccess else {
            return nil
        }
        return {
            do throws(AccountError) {
                try await checkAccess()
                return .reachable
            } catch {
                return error.status
            }
        }
    }
}
