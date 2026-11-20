//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct DatabaseChange: Sendable, Equatable {
    package enum Origin: Sendable, Equatable {
        case local
        case remote
    }

    package let backendID: String
    package let origin: Origin

    package let entities: Set<String>

    package let at: Date

    package init(backendID: String, origin: Origin, entities: Set<String> = [], at: Date = Date()) {
        self.backendID = backendID
        self.origin = origin
        self.entities = entities
        self.at = at
    }
}

extension DatabaseChange {
    func merged(with other: DatabaseChange) -> DatabaseChange {
        DatabaseChange(
            backendID: backendID,
            origin: origin == .remote || other.origin == .remote ? .remote : .local,
            entities: entities.union(other.entities),
            at: min(at, other.at)
        )
    }
}
