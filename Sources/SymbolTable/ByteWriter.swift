//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct ByteWriter {
    private(set) var bytes: [UInt8] = []

    mutating func write(unsigned: UInt64) {
        var value = unsigned
        repeat {
            let byte = UInt8(value & 0x7F)
            value >>= 7
            bytes.append(value == 0 ? byte : byte | 0x80)
        } while value != 0
    }

    mutating func write(signed: Int) {
        let value = Int64(signed)
        write(unsigned: UInt64(bitPattern: (value << 1) ^ (value >> 63)))
    }

    mutating func write(string: String) {
        let utf8 = Array(string.utf8)
        write(unsigned: UInt64(utf8.count))
        bytes += utf8
    }

    mutating func append(writer: ByteWriter) {
        bytes += writer.bytes
    }
}
