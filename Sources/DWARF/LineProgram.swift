//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable

struct LineProgram {
    let header: LineHeader
    var program: DataCursor

    init(cursor: inout DataCursor, strings: StringSections) throws {
        var length = UInt64(try cursor.read() as UInt32)
        let is64 = length == 0xFFFF_FFFF
        if is64 {
            length = try cursor.read()
        }
        let unitBytes = try cursor.readBytes(count: Int(exactly: length) ?? -1)
        var unit = DataCursor(bytes: unitBytes)

        let version: UInt16 = try unit.read()
        guard (2...5).contains(version) else {
            throw MalformedDWARFError()
        }
        if version >= 5 {
            _ = try unit.readBytes(count: 2)
        }
        let headerLength = try unit.readOffset(is64: is64)
        let programStart = unit.offset + (Int(exactly: headerLength) ?? -1)

        header = try LineHeader(cursor: &unit, version: version, is64: is64, strings: strings)
        try unit.seek(position: programStart)
        program = unit
    }

    mutating func sequences() throws -> [[Row]] {
        var sequences: [[Row]] = []
        var rows: [Row] = []
        var state = LineState()

        while !program.isAtEnd {
            let opcode: UInt8 = try program.read()

            if opcode >= header.opcodeBase {
                let adjusted = UInt64(opcode - header.opcodeBase)
                state.address &+= adjusted / header.lineRange * header.minimumInstructionLength
                state.line += header.lineBase + Int64(adjusted % header.lineRange)
                rows.append(state.row(header: header))
                continue
            }

            switch opcode {
            case 0:
                let length = Int(exactly: try program.readULEB()) ?? -1
                let operands = try program.readBytes(count: length)
                var extended = DataCursor(bytes: operands)
                switch try extended.read() as UInt8 {
                case 1:
                    rows.append(Row(address: state.address, location: nil))
                    sequences.append(rows)
                    rows = []
                    state = LineState()
                case 2:
                    state.address = try extended.read()
                default:
                    break
                }
            case 1:
                rows.append(state.row(header: header))
            case 2:
                state.address &+= try program.readULEB() * header.minimumInstructionLength
            case 3:
                state.line += try program.readSLEB()
            case 4:
                state.file = try program.readULEB()
            case 8:
                let adjusted = UInt64(255 - header.opcodeBase)
                state.address &+= adjusted / header.lineRange * header.minimumInstructionLength
            case 9:
                state.address &+= UInt64(try program.read() as UInt16)
            default:
                for _ in 0..<header.standardOpcodeLengths[Int(opcode) - 1] {
                    _ = try program.readULEB()
                }
            }
        }

        return sequences
    }
}

private struct LineState {
    var address: UInt64 = 0
    var file: UInt64 = 1
    var line: Int64 = 1

    func row(header: LineHeader) -> Row {
        let location = header.file(index: file).map { SymbolTable.Location(file: $0, line: Int(line)) }
        return Row(address: address, location: location)
    }
}

struct Row {
    let address: UInt64
    let location: SymbolTable.Location?
}
