//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct RangeList {
    let ranges: [Range<UInt64>]

    init(section: ArraySlice<UInt8>, offset: UInt64, base: UInt64, addressSize: Int, indexedAddress: (UInt64) throws -> UInt64) throws {
        var cursor = DataCursor(bytes: section)
        try cursor.seek(position: section.startIndex + Int(truncatingIfNeeded: offset))
        var base = base
        var ranges: [Range<UInt64>] = []

        while true {
            let kind: UInt8 = try cursor.read()
            switch kind {
            case 0:
                self.ranges = ranges
                return
            case 1:
                base = try indexedAddress(try cursor.readULEB())
            case 2:
                let start = try indexedAddress(try cursor.readULEB())
                ranges.append(try Self.range(start: start, end: try indexedAddress(try cursor.readULEB())))
            case 3:
                let start = try indexedAddress(try cursor.readULEB())
                ranges.append(try Self.range(start: start, length: try cursor.readULEB()))
            case 4:
                let start = try cursor.readULEB()
                ranges.append(try Self.range(start: base &+ start, end: base &+ (try cursor.readULEB())))
            case 5:
                base = try cursor.readSized(count: addressSize)
            case 6:
                let start = try cursor.readSized(count: addressSize)
                ranges.append(try Self.range(start: start, end: try cursor.readSized(count: addressSize)))
            case 7:
                let start = try cursor.readSized(count: addressSize)
                ranges.append(try Self.range(start: start, length: try cursor.readULEB()))
            default:
                throw MalformedDWARFError()
            }
        }
    }

    init(legacySection: ArraySlice<UInt8>, offset: UInt64, base: UInt64, addressSize: Int) throws {
        var cursor = DataCursor(bytes: legacySection)
        try cursor.seek(position: legacySection.startIndex + Int(truncatingIfNeeded: offset))
        let selection: UInt64 = addressSize == 8 ? .max : UInt64(UInt32.max)
        var base = base
        var ranges: [Range<UInt64>] = []

        while true {
            let start = try cursor.readSized(count: addressSize)
            let end = try cursor.readSized(count: addressSize)
            if start == 0, end == 0 {
                self.ranges = ranges
                return
            }
            if start == selection {
                base = end
            } else {
                ranges.append(try Self.range(start: base &+ start, end: base &+ end))
            }
        }
    }

    private static func range(start: UInt64, end: UInt64) throws -> Range<UInt64> {
        guard start <= end else {
            throw MalformedDWARFError()
        }
        return start..<end
    }

    private static func range(start: UInt64, length: UInt64) throws -> Range<UInt64> {
        let (end, overflow) = start.addingReportingOverflow(length)
        guard !overflow else {
            throw MalformedDWARFError()
        }
        return start..<end
    }
}
