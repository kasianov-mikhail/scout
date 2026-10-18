//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

private let pathContent: UInt64 = 1

struct LineHeader {
    let minimumInstructionLength: UInt64
    let lineBase: Int64
    let lineRange: UInt64
    let opcodeBase: UInt8
    let standardOpcodeLengths: [UInt8]
    let files: [String]
    let firstFileIndex: UInt64

    init(cursor: inout DataCursor, version: UInt16, is64: Bool, strings: StringSections) throws {
        minimumInstructionLength = UInt64(try cursor.read() as UInt8)
        if version >= 4 {
            _ = try cursor.read() as UInt8
        }
        _ = try cursor.read() as UInt8
        lineBase = Int64(Int8(bitPattern: try cursor.read()))
        lineRange = UInt64(try cursor.read() as UInt8)
        opcodeBase = try cursor.read()
        guard lineRange > 0, opcodeBase > 0 else {
            throw MalformedDWARFError()
        }
        standardOpcodeLengths = Array(try cursor.readBytes(count: Int(opcodeBase) - 1))

        if version >= 5 {
            _ = try Self.entries(cursor: &cursor, is64: is64, strings: strings)
            files = try Self.entries(cursor: &cursor, is64: is64, strings: strings)
            firstFileIndex = 0
        } else {
            while !(try cursor.readCString()).isEmpty {}
            files = try Self.legacyFiles(cursor: &cursor)
            firstFileIndex = 1
        }
    }

    func file(index: UInt64) -> String? {
        guard index >= firstFileIndex, index - firstFileIndex < UInt64(files.count) else {
            return nil
        }
        return files[Int(index - firstFileIndex)]
    }

    private static func legacyFiles(cursor: inout DataCursor) throws -> [String] {
        var files: [String] = []
        while true {
            let name = try cursor.readCString()
            guard !name.isEmpty else {
                return files
            }
            _ = try cursor.readULEB()
            _ = try cursor.readULEB()
            _ = try cursor.readULEB()
            files.append(name.lastPathComponent)
        }
    }

    private static func entries(cursor: inout DataCursor, is64: Bool, strings: StringSections) throws -> [String] {
        let formatCount: UInt8 = try cursor.read()
        var formats: [EntryFormat] = []
        for _ in 0..<formatCount {
            formats.append(EntryFormat(content: try cursor.readULEB(), form: try cursor.readULEB()))
        }

        let count = try cursor.readULEB()
        var names: [String] = []
        for _ in 0..<count {
            var name = ""
            for format in formats {
                let value = try strings.read(form: format.form, cursor: &cursor, is64: is64)
                if format.content == pathContent, let value {
                    name = value.lastPathComponent
                }
            }
            names.append(name)
        }
        return names
    }
}

private struct EntryFormat {
    let content: UInt64
    let form: UInt64
}

extension String {
    fileprivate var lastPathComponent: String {
        split(separator: "/").last.map(String.init) ?? self
    }
}
