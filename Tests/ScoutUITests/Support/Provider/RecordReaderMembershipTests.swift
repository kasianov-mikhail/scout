//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ConnectorSupport
@testable import ScoutUI

struct RecordReaderMembershipTests {
    @Test("readAll splits the values into membership reads of at most 250", arguments: zip([0, 250, 251], [[], [250], [250, 1]]))
    func readAllSplitsValues(count: Int, chunkSizes: [Int]) async throws {
        let values = (0..<count).map(String.init)
        let database = MembershipReader()

        let records = try await database.readAll(type: Event.self, field: "uuid", values: values, fields: nil)

        #expect(database.chunkSizes.sorted(by: >) == chunkSizes)
        #expect(records.map(\.recordID).sorted() == values.sorted())
    }
}

private final class MembershipReader: RecordReader, @unchecked Sendable {
    private let lock = NSLock()
    private var sizes: [Int] = []

    var chunkSizes: [Int] {
        lock.withLock { sizes }
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        guard case .strings(let values) = query.filters.first?.value else {
            throw MembershipFilterError()
        }
        lock.withLock { sizes.append(values.count) }
        return RecordChunk(records: values.map { Record(recordType: "Event", recordID: $0) }, cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }
}

private struct MembershipFilterError: Error {}
