//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable

private let maximumReferenceHops = 8

struct EntryCollector {
    let units: [CompileUnit]
    let sections: DebugSections
    let base: UInt64
    private(set) var functions: [SymbolTable.Function] = []
    private(set) var inlines: [SymbolTable.Inline] = []

    init(units: [CompileUnit], sections: DebugSections, base: UInt64) {
        self.units = units
        self.sections = sections
        self.base = base
    }

    mutating func collect(unit: CompileUnit) throws {
        guard unit.root.hasChildren else {
            return
        }

        var cursor = DataCursor(bytes: sections.info)
        try cursor.seek(position: unit.header.entriesStart)
        _ = try DebugEntry(cursor: &cursor, header: unit.header, abbreviations: unit.abbreviations)
        var depths = [0]

        while let parentDepth = depths.last, cursor.offset < unit.header.end {
            guard let entry = try DebugEntry(cursor: &cursor, header: unit.header, abbreviations: unit.abbreviations) else {
                depths.removeLast()
                continue
            }

            var depth = parentDepth
            switch entry.tag {
            case .subprogram:
                depth = 0
                try addFunction(entry: entry, unit: unit)
            case .inlinedSubroutine:
                depth = parentDepth + 1
                try addInline(entry: entry, unit: unit, depth: depth)
            default:
                break
            }

            if entry.hasChildren {
                depths.append(depth)
            }
        }
    }

    private mutating func addFunction(entry: DebugEntry, unit: CompileUnit) throws {
        let name = try name(entry: entry, unit: unit, hops: 0) ?? "???"
        for range in try offsets(ranges: unit.ranges(entry: entry)) {
            functions.append(SymbolTable.Function(start: range.lowerBound, end: range.upperBound, name: name))
        }
    }

    private mutating func addInline(entry: DebugEntry, unit: CompileUnit, depth: Int) throws {
        let name = try name(entry: entry, unit: unit, hops: 0) ?? "???"
        let file = entry[.callFile]?.number.flatMap { unit.lines?.file(index: $0) } ?? "???"
        let call = SymbolTable.Location(file: file, line: Int(truncatingIfNeeded: entry[.callLine]?.number ?? 0))

        for range in try offsets(ranges: unit.ranges(entry: entry)) {
            inlines.append(SymbolTable.Inline(start: range.lowerBound, end: range.upperBound, depth: depth, name: name, call: call))
        }
    }

    private func offsets(ranges: [Range<UInt64>]) -> [Range<UInt64>] {
        ranges.filter { $0.lowerBound >= base && !$0.isEmpty }.map { $0.lowerBound - base..<$0.upperBound - base }
    }

    private func name(entry: DebugEntry, unit: CompileUnit, hops: Int) throws -> String? {
        if let name = try unit.string(value: entry[.linkageName] ?? entry[.legacyLinkageName] ?? entry[.name]) {
            return name
        }
        guard hops < maximumReferenceHops, case .reference(let offset) = entry[.abstractOrigin] ?? entry[.specification] else {
            return nil
        }
        guard let owner = units.first(where: { $0.header.offset <= offset && offset < $0.header.end }) else {
            return nil
        }
        guard let target = try owner.entry(offset: offset) else {
            return nil
        }
        return try name(entry: target, unit: owner, hops: hops + 1)
    }
}
