//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB

actor ScanFlights {
    private var flights: [ScanKey: Task<[EntityRecord], any Error>] = [:]

    func records(key: ScanKey, scan: @escaping @Sendable () async throws -> [EntityRecord]) async throws -> [EntityRecord] {
        if let flight = flights[key] {
            return try await flight.value
        }

        let flight = Task { try await scan() }
        flights[key] = flight

        let result = await flight.result
        if flights[key] == flight {
            flights[key] = nil
        }
        return try result.get()
    }
}

struct ScanKey: Hashable {
    let entity: String
    let dateField: String
    let range: Range<Date>
}
