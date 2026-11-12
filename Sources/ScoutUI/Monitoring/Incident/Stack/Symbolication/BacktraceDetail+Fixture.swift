//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import SymbolTable

extension BacktraceDetail {
    static var sample: BacktraceDetail {
        detail(
            backtrace: .sample,
            symbols: [
                SampleSymbol(start: 0x3000, end: 0x3100, name: "FeedViewController.row(at:)", file: "FeedViewController.swift", line: 142),
                SampleSymbol(start: 0x4000, end: 0x4100, name: "FeedViewController.tableView(_:cellForRowAt:)", file: "FeedViewController.swift", line: 88),
                SampleSymbol(start: 0xC000, end: 0xC100, name: "main", file: "main.swift", line: 12),
            ]
        )
    }

    static var hangSample: BacktraceDetail {
        detail(
            backtrace: .hangSample,
            symbols: [
                SampleSymbol(start: 0x3000, end: 0x3100, name: "FeedCache.write(_:)", file: "FeedCache.swift", line: 58),
                SampleSymbol(start: 0x4000, end: 0x4100, name: "FeedViewController.viewWillDisappear(_:)", file: "FeedViewController.swift", line: 112),
                SampleSymbol(start: 0xC000, end: 0xC100, name: "main", file: "main.swift", line: 12),
            ]
        )
    }

    static var resourceSample: BacktraceDetail {
        detail(
            backtrace: .resourceSample,
            symbols: [
                SampleSymbol(start: 0x3000, end: 0x3100, name: "ImageCache.resize(_:to:)", file: "ImageCache.swift", line: 211),
                SampleSymbol(start: 0x4000, end: 0x4100, name: "ImageCache.resizeAll(_:)", file: "ImageCache.swift", line: 187),
                SampleSymbol(start: 0x5000, end: 0x5100, name: "FeedPrefetcher.prefetch(_:)", file: "FeedPrefetcher.swift", line: 93),
            ]
        )
    }

    private static func detail(backtrace: Backtrace, symbols: [SampleSymbol]) -> BacktraceDetail {
        guard let uuid = backtrace.images.first?.uuid else {
            return BacktraceDetail(backtrace: backtrace, tables: [:])
        }
        let table = SymbolTable(
            uuid: uuid,
            functions: symbols.map { SymbolTable.Function(start: $0.start, end: $0.end, name: $0.name) },
            lines: symbols.map { SymbolTable.Line(address: $0.start, location: SymbolTable.Location(file: $0.file, line: $0.line)) },
            inlines: []
        )
        return BacktraceDetail(backtrace: backtrace, tables: [uuid: table])
    }
}

private struct SampleSymbol {
    let start: UInt64
    let end: UInt64
    let name: String
    let file: String
    let line: Int
}
