//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct DebugEntry {
    let offset: Int
    let tag: Tag?
    let hasChildren: Bool
    private let attributes: [UInt64: AttributeValue]

    enum Tag: UInt64 {
        case compileUnit = 0x11
        case partialUnit = 0x3C
        case subprogram = 0x2E
        case inlinedSubroutine = 0x1D
    }

    enum Attribute: UInt64 {
        case name = 0x03
        case statementList = 0x10
        case lowAddress = 0x11
        case highAddress = 0x12
        case abstractOrigin = 0x31
        case specification = 0x47
        case ranges = 0x55
        case callFile = 0x58
        case callLine = 0x59
        case linkageName = 0x6E
        case stringOffsetsBase = 0x72
        case addressBase = 0x73
        case rangeListsBase = 0x74
        case legacyLinkageName = 0x2007
    }

    init?(cursor: inout DataCursor, header: UnitHeader, abbreviations: [UInt64: Abbreviation]) throws {
        let offset = cursor.offset
        let code = try cursor.readULEB()
        guard code != 0 else {
            return nil
        }
        guard let abbreviation = abbreviations[code] else {
            throw MalformedDWARFError()
        }

        var attributes: [UInt64: AttributeValue] = [:]
        for spec in abbreviation.attributes {
            attributes[spec.name] = try AttributeValue(form: spec.form, implicitValue: spec.implicitValue, cursor: &cursor, unit: header)
        }

        self.offset = offset
        self.tag = Tag(rawValue: abbreviation.tag)
        self.hasChildren = abbreviation.hasChildren
        self.attributes = attributes
    }

    subscript(attribute: Attribute) -> AttributeValue? {
        attributes[attribute.rawValue]
    }
}
