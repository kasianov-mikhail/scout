//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

enum AttributeValue {
    case address(UInt64)
    case addressIndex(UInt64)
    case constant(UInt64)
    case string(String)
    case stringOffset(UInt64)
    case lineStringOffset(UInt64)
    case stringIndex(UInt64)
    case reference(Int)
    case sectionOffset(UInt64)
    case rangeListIndex(UInt64)
    case other

    init(form: Abbreviation.Form, implicitValue: Int64, cursor: inout DataCursor, unit: UnitHeader) throws {
        switch form {
        case .address:
            self = .address(try cursor.readSized(count: unit.addressSize))
        case .addrx:
            self = .addressIndex(try cursor.readULEB())
        case .addrx1, .addrx2, .addrx3, .addrx4:
            self = .addressIndex(try cursor.readSized(count: form.fixedSize ?? 0))
        case .data1, .data2, .data4, .data8:
            self = .constant(try cursor.readSized(count: form.fixedSize ?? 0))
        case .udata:
            self = .constant(try cursor.readULEB())
        case .sdata:
            self = .constant(UInt64(bitPattern: try cursor.readSLEB()))
        case .implicitConst:
            self = .constant(UInt64(bitPattern: implicitValue))
        case .string:
            self = .string(try cursor.readCString())
        case .strp:
            self = .stringOffset(try cursor.readOffset(is64: unit.is64))
        case .lineStrp:
            self = .lineStringOffset(try cursor.readOffset(is64: unit.is64))
        case .strx:
            self = .stringIndex(try cursor.readULEB())
        case .strx1, .strx2, .strx3, .strx4:
            self = .stringIndex(try cursor.readSized(count: form.fixedSize ?? 0))
        case .ref1, .ref2, .ref4, .ref8:
            self = .reference(unit.offset + Int(truncatingIfNeeded: try cursor.readSized(count: form.fixedSize ?? 0)))
        case .refUData:
            self = .reference(unit.offset + Int(truncatingIfNeeded: try cursor.readULEB()))
        case .refAddress:
            let offset = unit.version <= 2 ? try cursor.readSized(count: unit.addressSize) : try cursor.readOffset(is64: unit.is64)
            self = .reference(Int(truncatingIfNeeded: offset))
        case .sectionOffset:
            self = .sectionOffset(try cursor.readOffset(is64: unit.is64))
        case .rnglistx:
            self = .rangeListIndex(try cursor.readULEB())
        case .indirect:
            guard let indirect = Abbreviation.Form(rawValue: try cursor.readULEB()) else {
                throw MalformedDWARFError()
            }
            try self.init(form: indirect, implicitValue: implicitValue, cursor: &cursor, unit: unit)
        default:
            try Self.skip(form: form, cursor: &cursor, unit: unit)
            self = .other
        }
    }

    private static func skip(form: Abbreviation.Form, cursor: inout DataCursor, unit: UnitHeader) throws {
        switch form {
        case .block1:
            _ = try cursor.readBytes(count: Int(try cursor.read() as UInt8))
        case .block2:
            _ = try cursor.readBytes(count: Int(try cursor.read() as UInt16))
        case .block4:
            _ = try cursor.readBytes(count: Int(try cursor.read() as UInt32))
        case .block, .exprloc:
            _ = try cursor.readBytes(count: Int(exactly: try cursor.readULEB()) ?? -1)
        case .strpSup:
            _ = try cursor.readOffset(is64: unit.is64)
        case .loclistx:
            _ = try cursor.readULEB()
        default:
            guard let size = form.fixedSize else {
                throw MalformedDWARFError()
            }
            _ = try cursor.readBytes(count: size)
        }
    }
}

extension AttributeValue {
    var number: UInt64? {
        switch self {
        case .constant(let value), .sectionOffset(let value):
            value
        default:
            nil
        }
    }
}
