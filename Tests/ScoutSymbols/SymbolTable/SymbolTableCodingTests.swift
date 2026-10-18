//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import SymbolTable

@Suite("SymbolTable coding")
struct SymbolTableCodingTests {
    let table = SymbolTable.sample

    @Test("A table survives encoding and decoding")
    func roundTrip() throws {
        #expect(try SymbolTable(data: table.data) == table)
    }

    @Test("The header names the format and the image UUID before the compressed body")
    func header() throws {
        let data = try table.data

        #expect(Array(data.prefix(4)) == Array("SSYM".utf8))
        #expect(UUID(uuid: data.subdata(in: 8..<24).withUnsafeBytes { $0.loadUnaligned(as: uuid_t.self) }) == table.uuid)
    }

    @Test("Truncated data is rejected instead of trapping")
    func truncated() throws {
        let data = try table.data

        for length in stride(from: 0, to: data.count, by: 7) {
            #expect(throws: (any Error).self) { try SymbolTable(data: data.prefix(length)) }
        }
    }

    @Test("Data in another format is rejected")
    func foreignData() {
        #expect(throws: MalformedSymbolTableError.self) { try SymbolTable(data: Data(repeating: 0, count: 64)) }
    }
}
