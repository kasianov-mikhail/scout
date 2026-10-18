//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

package struct SymbolFileHeader: Equatable, Sendable {
    static let size = 24

    package let uuid: UUID

    package init(data: Data) throws {
        let bytes = [UInt8](data.prefix(Self.size))
        guard bytes.count == Self.size else {
            throw MalformedSymbolTableError()
        }
        guard bytes[0..<4].elementsEqual(formatMagic), bytes[4..<8].elementsEqual(formatVersion) else {
            throw MalformedSymbolTableError()
        }
        uuid = UUID(uuid: bytes[8..<Self.size].withUnsafeBytes { $0.loadUnaligned(as: uuid_t.self) })
    }
}
