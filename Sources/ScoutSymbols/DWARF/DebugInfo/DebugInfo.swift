//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable

struct DebugInfo {
    let functions: [SymbolTable.Function]
    let inlines: [SymbolTable.Inline]

    init(image: MachOImage) throws {
        let sections = DebugSections(image: image)
        var units: [CompileUnit] = []
        var cursor = DataCursor(bytes: sections.info)

        while !cursor.isAtEnd {
            let header = try UnitHeader(cursor: &cursor)
            if header.isCompileUnit {
                units.append(try CompileUnit(header: header, sections: sections))
            }
            try cursor.seek(position: header.end)
        }

        var collector = EntryCollector(units: units, sections: sections, base: image.textAddress)
        for unit in units {
            try collector.collect(unit: unit)
        }

        functions = collector.functions
        inlines = collector.inlines
    }
}
