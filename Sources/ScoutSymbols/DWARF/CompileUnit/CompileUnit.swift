//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct CompileUnit {
    let header: UnitHeader
    let abbreviations: [UInt64: Abbreviation]
    let root: DebugEntry

    private(set) var baseAddress: UInt64 = 0
    private(set) var lines: LineHeader?
    private let stringOffsetsBase: UInt64
    private let addressBase: UInt64
    let rangeListsBase: UInt64
    let sections: DebugSections

    init(header: UnitHeader, sections: DebugSections) throws {
        let abbreviations = try Abbreviation.table(section: sections.abbreviations, offset: header.abbreviationOffset)
        var cursor = DataCursor(bytes: sections.info)
        try cursor.seek(position: header.entriesStart)

        guard let root = try DebugEntry(cursor: &cursor, header: header, abbreviations: abbreviations) else {
            throw MalformedDWARFError()
        }

        self.header = header
        self.abbreviations = abbreviations
        self.root = root
        self.sections = sections
        self.stringOffsetsBase = root[.stringOffsetsBase]?.number ?? (header.is64 ? 16 : 8)
        self.addressBase = root[.addressBase]?.number ?? 8
        self.rangeListsBase = root[.rangeListsBase]?.number ?? 0
        self.baseAddress = try address(value: root[.lowAddress]) ?? 0
        self.lines = try root[.statementList]?.number.map(lineHeader)
    }

    func entry(offset: Int) throws -> DebugEntry? {
        var cursor = DataCursor(bytes: sections.info)
        try cursor.seek(position: offset)
        return try DebugEntry(cursor: &cursor, header: header, abbreviations: abbreviations)
    }

    func string(value: AttributeValue?) throws -> String? {
        switch value {
        case .string(let string):
            string
        case .stringOffset(let offset):
            try sections.strings.string(section: sections.strings.debugStrings, offset: offset)
        case .lineStringOffset(let offset):
            try sections.strings.string(section: sections.strings.lineStrings, offset: offset)
        case .stringIndex(let index):
            try sections.strings.string(
                section: sections.strings.debugStrings,
                offset: try entryOffset(section: sections.stringOffsets, base: stringOffsetsBase, index: index)
            )
        default:
            nil
        }
    }

    func address(value: AttributeValue?) throws -> UInt64? {
        switch value {
        case .address(let address):
            address
        case .addressIndex(let index):
            try indexedAddress(index: index)
        default:
            nil
        }
    }

    func indexedAddress(index: UInt64) throws -> UInt64 {
        let position = addressBase + index * UInt64(header.addressSize)
        var cursor = DataCursor(bytes: sections.addresses)
        try cursor.seek(position: Int(truncatingIfNeeded: position))
        return try cursor.readSized(count: header.addressSize)
    }

    func entryOffset(section: ArraySlice<UInt8>, base: UInt64, index: UInt64) throws -> UInt64 {
        var cursor = DataCursor(bytes: section)
        let size: UInt64 = header.is64 ? 8 : 4
        try cursor.seek(position: Int(truncatingIfNeeded: base + index * size))
        return try cursor.readOffset(is64: header.is64)
    }

    private func lineHeader(offset: UInt64) throws -> LineHeader {
        var cursor = DataCursor(bytes: sections.lines)
        try cursor.seek(position: Int(truncatingIfNeeded: offset))
        return try LineProgram(cursor: &cursor, strings: sections.strings).header
    }
}
