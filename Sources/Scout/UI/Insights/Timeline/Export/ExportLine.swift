//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

enum ExportLine {
    case heading(level: Int, String)
    case text(String)
    case bullet(String)
    case code([String])
    case blank
}

extension ExportLine {
    fileprivate var rendered: [String] {
        switch self {
        case .heading(let level, let text):
            [String(repeating: "#", count: level) + " " + text]
        case .text(let text):
            [text]
        case .bullet(let text):
            ["- " + text]
        case .code(let lines):
            ["```"] + lines + ["```"]
        case .blank:
            [""]
        }
    }
}

extension [ExportLine] {
    var text: String {
        flatMap(\.rendered).joined(separator: "\n")
    }
}
