//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct MachOSegment {
    let name: String
    let address: UInt64
    let sections: [String: ArraySlice<UInt8>]

    init(cursor: inout DataCursor, slice: ArraySlice<UInt8>) throws {
        name = try cursor.readFixedString(count: 16)
        address = try cursor.read()
        _ = try cursor.readBytes(count: 32)
        let count: UInt32 = try cursor.read()
        _ = try cursor.readBytes(count: 4)

        var sections: [String: ArraySlice<UInt8>] = [:]
        for _ in 0..<count {
            let sectionName = try cursor.readFixedString(count: 16)
            _ = try cursor.readBytes(count: 24)
            let size: UInt64 = try cursor.read()
            let offset: UInt32 = try cursor.read()
            _ = try cursor.readBytes(count: 28)

            let start = slice.startIndex + Int(offset)
            guard size <= UInt64(slice.endIndex - start) else {
                throw MalformedDWARFError()
            }
            sections[sectionName] = slice[start..<start + Int(size)]
        }
        self.sections = sections
    }
}
