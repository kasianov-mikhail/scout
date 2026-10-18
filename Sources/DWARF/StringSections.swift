//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct StringSections {
    let debugStrings: ArraySlice<UInt8>
    let lineStrings: ArraySlice<UInt8>

    func read(form: UInt64, cursor: inout DataCursor, is64: Bool) throws -> String? {
        switch form {
        case 0x08:
            return try cursor.readCString()
        case 0x0E:
            return try string(section: debugStrings, offset: try cursor.readOffset(is64: is64))
        case 0x1F:
            return try string(section: lineStrings, offset: try cursor.readOffset(is64: is64))
        case 0x0B:
            _ = try cursor.readBytes(count: 1)
        case 0x05:
            _ = try cursor.readBytes(count: 2)
        case 0x06:
            _ = try cursor.readBytes(count: 4)
        case 0x07:
            _ = try cursor.readBytes(count: 8)
        case 0x1E:
            _ = try cursor.readBytes(count: 16)
        case 0x0F:
            _ = try cursor.readULEB()
        case 0x09:
            _ = try cursor.readBytes(count: Int(try cursor.readULEB()))
        default:
            throw MalformedDWARFError()
        }
        return nil
    }

    private func string(section: ArraySlice<UInt8>, offset: UInt64) throws -> String {
        guard offset < UInt64(section.count) else {
            throw MalformedDWARFError()
        }
        var cursor = DataCursor(bytes: section[(section.startIndex + Int(offset))...])
        return try cursor.readCString()
    }
}
