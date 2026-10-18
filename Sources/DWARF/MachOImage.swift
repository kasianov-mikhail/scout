//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

private let magic64: UInt32 = 0xFEED_FACF
private let fatMagic: UInt32 = 0xCAFE_BABE
private let arm64: UInt32 = 0x0100_000C
private let segmentCommand: UInt32 = 0x19
private let uuidCommand: UInt32 = 0x1B

package struct MachOImage {
    package let uuid: UUID
    package let textAddress: UInt64
    private let sections: [String: ArraySlice<UInt8>]

    package init(data: Data) throws {
        let bytes = [UInt8](data)
        let slice = try Self.arm64Slice(bytes: bytes)
        var cursor = DataCursor(bytes: slice)

        let magic: UInt32 = try cursor.read()
        guard magic == magic64 else {
            throw MalformedDWARFError()
        }
        _ = try cursor.readBytes(count: 12)
        let commandCount: UInt32 = try cursor.read()
        _ = try cursor.readBytes(count: 12)

        var uuid: UUID?
        var textAddress: UInt64?
        var sections: [String: ArraySlice<UInt8>] = [:]

        for _ in 0..<commandCount {
            let start = cursor.offset
            let command: UInt32 = try cursor.read()
            let size: UInt32 = try cursor.read()

            switch command {
            case uuidCommand:
                uuid = UUID(uuid: try cursor.readBytes(count: 16).withUnsafeBytes { $0.loadUnaligned(as: uuid_t.self) })
            case segmentCommand:
                let segment = try MachOSegment(cursor: &cursor, slice: slice)
                if segment.name == "__TEXT" {
                    textAddress = segment.address
                }
                if segment.name == "__DWARF" {
                    sections.merge(segment.sections) { first, _ in first }
                }
            default:
                break
            }

            try cursor.seek(position: start + Int(size))
        }

        guard let uuid, let textAddress else {
            throw MalformedDWARFError()
        }
        self.uuid = uuid
        self.textAddress = textAddress
        self.sections = sections
    }

    package func section(name: String) -> ArraySlice<UInt8> {
        sections[name] ?? []
    }

    private static func arm64Slice(bytes: [UInt8]) throws -> ArraySlice<UInt8> {
        var cursor = DataCursor(bytes: bytes[...])
        let magic: UInt32 = try cursor.readBigEndian()
        guard magic == fatMagic else {
            return bytes[...]
        }

        let count: UInt32 = try cursor.readBigEndian()
        for _ in 0..<count {
            let cpu: UInt32 = try cursor.readBigEndian()
            _ = try cursor.readBytes(count: 4)
            let offset: UInt32 = try cursor.readBigEndian()
            let size: UInt32 = try cursor.readBigEndian()
            _ = try cursor.readBytes(count: 4)

            guard cpu == arm64 else {
                continue
            }
            guard Int(offset) + Int(size) <= bytes.count else {
                throw MalformedDWARFError()
            }
            return bytes[Int(offset)..<Int(offset) + Int(size)]
        }
        throw MalformedDWARFError()
    }
}
