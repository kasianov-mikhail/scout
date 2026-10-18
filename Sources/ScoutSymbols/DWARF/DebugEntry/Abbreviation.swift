//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct Abbreviation {
    let tag: UInt64
    let hasChildren: Bool
    let attributes: [AttributeSpec]

    struct AttributeSpec {
        let name: UInt64
        let form: Form
        let implicitValue: Int64
    }

    static func table(section: ArraySlice<UInt8>, offset: Int) throws -> [UInt64: Abbreviation] {
        var cursor = DataCursor(bytes: section)
        try cursor.seek(position: section.startIndex + offset)
        var table: [UInt64: Abbreviation] = [:]

        while true {
            let code = try cursor.readULEB()
            guard code != 0 else {
                return table
            }
            let tag = try cursor.readULEB()
            let hasChildren: UInt8 = try cursor.read()

            var attributes: [AttributeSpec] = []
            while true {
                let name = try cursor.readULEB()
                let rawForm = try cursor.readULEB()
                guard name != 0 || rawForm != 0 else {
                    break
                }
                guard let form = Form(rawValue: rawForm) else {
                    throw MalformedDWARFError()
                }
                let implicitValue = form == .implicitConst ? try cursor.readSLEB() : 0
                attributes.append(AttributeSpec(name: name, form: form, implicitValue: implicitValue))
            }

            table[code] = Abbreviation(tag: tag, hasChildren: hasChildren != 0, attributes: attributes)
        }
    }
}
