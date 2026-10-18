//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct UnitHeader {
    let offset: Int
    let end: Int
    let version: UInt16
    let is64: Bool
    let addressSize: Int
    let isCompileUnit: Bool
    let abbreviationOffset: Int
    let entriesStart: Int

    init(cursor: inout DataCursor) throws {
        offset = cursor.offset
        var length = UInt64(try cursor.read() as UInt32)
        is64 = length == 0xFFFF_FFFF
        if is64 {
            length = try cursor.read()
        }
        let lengthEnd = cursor.offset
        end = lengthEnd + (Int(exactly: length) ?? -1)
        guard end >= lengthEnd, end <= cursor.bytes.endIndex else {
            throw MalformedDWARFError()
        }

        version = try cursor.read()
        guard (2...5).contains(version) else {
            throw MalformedDWARFError()
        }

        if version >= 5 {
            let kind: UInt8 = try cursor.read()
            addressSize = Int(try cursor.read() as UInt8)
            abbreviationOffset = Int(truncatingIfNeeded: try cursor.readOffset(is64: is64))
            isCompileUnit = kind == 1 || kind == 3
        } else {
            abbreviationOffset = Int(truncatingIfNeeded: try cursor.readOffset(is64: is64))
            addressSize = Int(try cursor.read() as UInt8)
            isCompileUnit = true
        }
        entriesStart = cursor.offset
    }
}
