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

struct IncidentLocation: Equatable {
    let file: String
    let line: Int

    var fileName: String {
        (file as NSString).lastPathComponent
    }

    var text: String {
        "\(fileName):\(line)"
    }
}

struct IncidentStackRow: Identifiable {
    let id: Int
    let image: String
    let symbol: String?
    let location: IncidentLocation?

    var bareSymbol: String? {
        guard let symbol else {
            return nil
        }
        guard let paren = symbol.firstIndex(of: "(") else {
            return symbol
        }
        let name = symbol[..<paren]
        guard let dot = name.lastIndex(of: ".") else {
            return symbol
        }
        return String(symbol[symbol.index(after: dot)...])
    }
}

extension IncidentStackRow {
    init(line: String, index: Int) {
        let tokens = line.split(whereSeparator: \.isWhitespace)
        if tokens.count < 2 {
            id = index
            image = ""
            symbol = line.trimmingCharacters(in: .whitespaces)
            location = nil
            return
        }

        var rest = Array(tokens.dropFirst(2))
        if rest.first?.hasPrefix("0x") == true {
            rest.removeFirst()
        }
        var text = rest.joined(separator: " ")
        if let range = text.range(of: " + ", options: .backwards) {
            text = String(text[..<range.lowerBound])
        }

        id = index
        image = String(tokens[1])
        symbol = text.isEmpty ? nil : text
        location = nil
    }
}

struct IncidentStack {
    let rows: [IncidentStackRow]

    init(detail: BacktraceDetail?, fallback: [String]) {
        let frames = detail?.attributedFrames ?? []
        if frames.isEmpty {
            rows = fallback.enumerated().map { index, line in IncidentStackRow(line: line, index: index) }
            return
        }

        rows = frames.map { frame in
            let symbol = frame.symbols.first
            let parsed = fallback.indices.contains(frame.index) ? IncidentStackRow(line: fallback[frame.index], index: frame.index) : nil
            return IncidentStackRow(
                id: frame.index,
                image: frame.image?.name ?? parsed?.image ?? "???",
                symbol: symbol?.name ?? parsed?.symbol,
                location: symbol?.location.map { IncidentLocation(file: $0.file, line: $0.line) }
            )
        }
    }

    var culprit: IncidentStackRow? {
        rows.first { $0.location != nil }
    }

    var caller: IncidentStackRow? {
        guard let index = rows.firstIndex(where: { $0.location != nil }) else {
            return nil
        }
        return rows.dropFirst(index + 1).first { $0.location != nil }
    }

    var isSymbolicated: Bool {
        rows.contains { $0.location != nil }
    }
}
