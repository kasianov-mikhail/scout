//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct ByteReader {
    let bytes: [UInt8]
    private var offset = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    mutating func read() throws -> UInt64 {
        var value: UInt64 = 0
        var shift: UInt64 = 0

        while true {
            guard offset < bytes.count, shift < 64 else {
                throw MalformedSymbolTableError()
            }
            let byte = bytes[offset]
            offset += 1
            value |= UInt64(byte & 0x7F) << shift
            guard byte & 0x80 != 0 else {
                return value
            }
            shift += 7
        }
    }

    mutating func read(after: UInt64) throws -> UInt64 {
        let (sum, overflow) = after.addingReportingOverflow(try read())
        guard !overflow else {
            throw MalformedSymbolTableError()
        }
        return sum
    }

    mutating func readInt() throws -> Int {
        guard let value = Int(exactly: try read()) else {
            throw MalformedSymbolTableError()
        }
        return value
    }

    mutating func readSigned() throws -> Int {
        let value = try read()
        return Int(truncatingIfNeeded: Int64(bitPattern: (value >> 1) ^ (0 &- (value & 1))))
    }

    mutating func readCount() throws -> Int {
        let count = try readInt()
        guard count <= bytes.count - offset else {
            throw MalformedSymbolTableError()
        }
        return count
    }

    mutating func readString() throws -> String {
        let count = try readCount()
        defer { offset += count }
        return String(decoding: bytes[offset..<offset + count], as: UTF8.self)
    }
}
