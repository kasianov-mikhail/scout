//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct DebugSections {
    let info: ArraySlice<UInt8>
    let abbreviations: ArraySlice<UInt8>
    let addresses: ArraySlice<UInt8>
    let rangeLists: ArraySlice<UInt8>
    let legacyRanges: ArraySlice<UInt8>
    let lines: ArraySlice<UInt8>
    let stringOffsets: ArraySlice<UInt8>
    let strings: StringSections

    init(image: MachOImage) {
        func section(name: String) -> ArraySlice<UInt8> {
            Array(image.section(name: name))[...]
        }

        info = section(name: "__debug_info")
        abbreviations = section(name: "__debug_abbrev")
        addresses = section(name: "__debug_addr")
        rangeLists = section(name: "__debug_rnglists")
        legacyRanges = section(name: "__debug_ranges")
        lines = section(name: "__debug_line")
        stringOffsets = section(name: "__debug_str_offs")
        strings = StringSections(debugStrings: section(name: "__debug_str"), lineStrings: section(name: "__debug_line_str"))
    }
}
