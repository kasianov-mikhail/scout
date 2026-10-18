//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

package struct MalformedSymbolTableError: Error {}

extension SymbolTable {
    package init(data: Data) throws {
        let header = try SymbolFileHeader(data: data)
        let payload = try (Data(data.dropFirst(SymbolFileHeader.size)) as NSData).decompressed(using: .zlib) as Data
        var reader = ByteReader(bytes: [UInt8](payload))
        let strings = try (0..<reader.readCount()).map { _ in try reader.readString() }

        self.init(
            uuid: header.uuid,
            functions: try reader.functions(strings: strings),
            lines: try reader.lines(strings: strings),
            inlines: try reader.inlines(strings: strings)
        )
    }
}

extension ByteReader {
    fileprivate mutating func functions(strings: [String]) throws -> [SymbolTable.Function] {
        var functions: [SymbolTable.Function] = []
        var previous: UInt64 = 0
        for _ in 0..<(try readCount()) {
            let start = try read(after: previous)
            let end = try read(after: start)
            functions.append(SymbolTable.Function(start: start, end: end, name: try string(strings: strings)))
            previous = start
        }
        return functions
    }

    fileprivate mutating func lines(strings: [String]) throws -> [SymbolTable.Line] {
        var lines: [SymbolTable.Line] = []
        var previous: UInt64 = 0
        var previousLine = 0
        for _ in 0..<(try readCount()) {
            let address = try read(after: previous)
            previous = address
            let file = try readInt()
            guard file > 0 else {
                lines.append(SymbolTable.Line(address: address, location: nil))
                continue
            }
            guard file <= strings.count else {
                throw MalformedSymbolTableError()
            }
            previousLine += try readSigned()
            let location = SymbolTable.Location(file: strings[file - 1], line: previousLine)
            lines.append(SymbolTable.Line(address: address, location: location))
        }
        return lines
    }

    fileprivate mutating func inlines(strings: [String]) throws -> [SymbolTable.Inline] {
        var inlines: [SymbolTable.Inline] = []
        var previous: UInt64 = 0
        for _ in 0..<(try readCount()) {
            let start = try read(after: previous)
            let end = try read(after: start)
            let depth = try readInt()
            let name = try string(strings: strings)
            let call = SymbolTable.Location(file: try string(strings: strings), line: try readInt())
            inlines.append(SymbolTable.Inline(start: start, end: end, depth: depth, name: name, call: call))
            previous = start
        }
        return inlines
    }

    private mutating func string(strings: [String]) throws -> String {
        let index = try readInt()
        guard strings.indices.contains(index) else {
            throw MalformedSymbolTableError()
        }
        return strings[index]
    }
}
