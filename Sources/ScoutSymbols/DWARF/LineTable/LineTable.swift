//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable

struct LineTable {
    let lines: [SymbolTable.Line]

    init(image: MachOImage) throws {
        let strings = StringSections(
            debugStrings: image.section(name: "__debug_str"),
            lineStrings: image.section(name: "__debug_line_str")
        )
        try self.init(section: image.section(name: "__debug_line"), strings: strings, base: image.textAddress)
    }

    init(section: ArraySlice<UInt8>, strings: StringSections, base: UInt64) throws {
        var cursor = DataCursor(bytes: section)
        var lines: [SymbolTable.Line] = []

        while !cursor.isAtEnd {
            var program = try LineProgram(cursor: &cursor, strings: strings)
            for sequence in try program.sequences() where sequence.first?.address ?? 0 >= base {
                lines += sequence.offsets(base: base)
            }
        }

        self.lines = lines
    }
}

extension [Row] {
    fileprivate func offsets(base: UInt64) -> [SymbolTable.Line] {
        var lines: [SymbolTable.Line] = []
        for row in self where row.location == nil || row.location != lines.last?.location {
            lines.append(SymbolTable.Line(address: row.address - base, location: row.location))
        }
        return lines
    }
}
