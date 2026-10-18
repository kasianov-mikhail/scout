//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension CompileUnit {
    func ranges(entry: DebugEntry) throws -> [Range<UInt64>] {
        if let low = try address(value: entry[.lowAddress]) {
            switch entry[.highAddress] {
            case .constant(let length):
                return [low..<low + length]
            case let value:
                guard let high = try address(value: value), high >= low else {
                    return []
                }
                return [low..<high]
            }
        }

        switch entry[.ranges] {
        case .rangeListIndex(let index) where header.version >= 5:
            let offset = try entryOffset(section: sections.rangeLists, base: rangeListsBase, index: index)
            return try rangeList(offset: rangeListsBase + offset)
        case .sectionOffset(let offset) where header.version >= 5:
            return try rangeList(offset: offset)
        case .sectionOffset(let offset), .constant(let offset):
            return try RangeList(legacySection: sections.legacyRanges, offset: offset, base: baseAddress, addressSize: header.addressSize).ranges
        default:
            return []
        }
    }

    private func rangeList(offset: UInt64) throws -> [Range<UInt64>] {
        try RangeList(
            section: sections.rangeLists,
            offset: offset,
            base: baseAddress,
            addressSize: header.addressSize,
            indexedAddress: indexedAddress
        )
        .ranges
    }
}
