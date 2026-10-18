//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

let formatMagic: [UInt8] = Array("SSYM".utf8)
let formatVersion: [UInt8] = [1, 0, 0, 0]

extension SymbolTable {
    package var data: Data {
        get throws {
            var strings = StringTable()
            var records = ByteWriter()
            records.write(functions: functions, strings: &strings)
            records.write(lines: lines, strings: &strings)
            records.write(inlines: inlines, strings: &strings)

            var payload = ByteWriter()
            payload.write(unsigned: UInt64(strings.values.count))
            for value in strings.values {
                payload.write(string: value)
            }
            payload.append(writer: records)

            let header = Data(formatMagic + formatVersion) + withUnsafeBytes(of: uuid.uuid) { Data($0) }
            return try header + (Data(payload.bytes) as NSData).compressed(using: .zlib)
        }
    }
}

private struct StringTable {
    private(set) var values: [String] = []
    private var indices: [String: UInt64] = [:]

    mutating func index(value: String) -> UInt64 {
        if let index = indices[value] {
            return index
        }
        let index = UInt64(values.count)
        values.append(value)
        indices[value] = index
        return index
    }
}

extension ByteWriter {
    fileprivate mutating func write(functions: [SymbolTable.Function], strings: inout StringTable) {
        write(unsigned: UInt64(functions.count))
        var previous: UInt64 = 0
        for function in functions {
            write(unsigned: function.start - previous)
            write(unsigned: function.end - function.start)
            write(unsigned: strings.index(value: function.name))
            previous = function.start
        }
    }

    fileprivate mutating func write(lines: [SymbolTable.Line], strings: inout StringTable) {
        write(unsigned: UInt64(lines.count))
        var previous: UInt64 = 0
        var previousLine = 0
        for line in lines {
            write(unsigned: line.address - previous)
            previous = line.address
            guard let location = line.location else {
                write(unsigned: 0)
                continue
            }
            write(unsigned: strings.index(value: location.file) + 1)
            write(signed: location.line - previousLine)
            previousLine = location.line
        }
    }

    fileprivate mutating func write(inlines: [SymbolTable.Inline], strings: inout StringTable) {
        write(unsigned: UInt64(inlines.count))
        var previous: UInt64 = 0
        for inline in inlines {
            write(unsigned: inline.start - previous)
            write(unsigned: inline.end - inline.start)
            write(unsigned: UInt64(inline.depth))
            write(unsigned: strings.index(value: inline.name))
            write(unsigned: strings.index(value: inline.call.file))
            write(unsigned: UInt64(inline.call.line))
            previous = inline.start
        }
    }
}
