//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

package struct MalformedDWARFError: Error {}

struct DataCursor {
    let bytes: ArraySlice<UInt8>
    private(set) var offset: Int

    init(bytes: ArraySlice<UInt8>) {
        self.bytes = bytes
        self.offset = bytes.startIndex
    }

    var isAtEnd: Bool {
        offset >= bytes.endIndex
    }

    mutating func read<Value: FixedWidthInteger & UnsignedInteger>() throws -> Value {
        let size = MemoryLayout<Value>.size
        guard size <= bytes.endIndex - offset else {
            throw MalformedDWARFError()
        }
        defer { offset += size }
        return bytes[offset..<offset + size].reversed().reduce(0) { $0 << 8 | Value($1) }
    }

    mutating func readBigEndian<Value: FixedWidthInteger & UnsignedInteger>() throws -> Value {
        let value: Value = try read()
        return value.byteSwapped
    }

    mutating func readULEB() throws -> UInt64 {
        var value: UInt64 = 0
        var shift: UInt64 = 0

        while true {
            let byte: UInt8 = try read()
            guard shift < 64 else {
                throw MalformedDWARFError()
            }
            value |= UInt64(byte & 0x7F) << shift
            shift += 7
            guard byte & 0x80 != 0 else {
                return value
            }
        }
    }

    mutating func readSLEB() throws -> Int64 {
        var value: Int64 = 0
        var shift: Int64 = 0
        var byte: UInt8

        repeat {
            byte = try read()
            guard shift < 64 else {
                throw MalformedDWARFError()
            }
            value |= Int64(byte & 0x7F) << shift
            shift += 7
        } while byte & 0x80 != 0

        if shift < 64, byte & 0x40 != 0 {
            value |= -1 << shift
        }
        return value
    }

    mutating func readCString() throws -> String {
        guard let end = bytes[offset...].firstIndex(of: 0) else {
            throw MalformedDWARFError()
        }
        defer { offset = end + 1 }
        return String(decoding: bytes[offset..<end], as: UTF8.self)
    }

    mutating func readFixedString(count: Int) throws -> String {
        let raw = try readBytes(count: count)
        return String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
    }

    mutating func readBytes(count: Int) throws -> ArraySlice<UInt8> {
        guard count >= 0, count <= bytes.endIndex - offset else {
            throw MalformedDWARFError()
        }
        defer { offset += count }
        return bytes[offset..<offset + count]
    }

    mutating func seek(position: Int) throws {
        guard position >= offset, position <= bytes.endIndex else {
            throw MalformedDWARFError()
        }
        offset = position
    }

    mutating func readOffset(is64: Bool) throws -> UInt64 {
        is64 ? try read() : UInt64(try read() as UInt32)
    }

    mutating func readSized(count: Int) throws -> UInt64 {
        guard (0...8).contains(count) else {
            throw MalformedDWARFError()
        }
        return try readBytes(count: count).reversed().reduce(0) { $0 << 8 | UInt64($1) }
    }
}
