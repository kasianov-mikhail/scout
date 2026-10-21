//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB

actor SeriesFlights {
    private var flights: [SeriesRead: Task<[SeriesPoint], any Error>] = [:]

    func points(read: SeriesRead, fetch: @escaping @Sendable () async throws -> [SeriesPoint]) async throws -> [SeriesPoint] {
        if let flight = flights[read] {
            return try await flight.value
        }

        let flight = Task { try await fetch() }
        flights[read] = flight

        let result = await flight.result
        if flights[read] == flight {
            flights[read] = nil
        }
        return try result.get()
    }
}

struct SeriesRead: Hashable {
    let entity: String
    let field: String?
    let group: String
    let range: Range<Date>
}
