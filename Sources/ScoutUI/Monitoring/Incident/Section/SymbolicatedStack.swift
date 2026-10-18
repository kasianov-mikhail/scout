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

struct SymbolicatedStack: Equatable {
    let lines: [String]

    init?(detail: BacktraceDetail, fallback: [String]) {
        guard let thread = detail.backtrace.threads.first(where: \.attributed) else {
            return nil
        }

        var lines: [String] = []
        var isSymbolicated = false

        for (index, frame) in thread.frames.enumerated() {
            let image = frame.image.flatMap { detail.backtrace.images.indices.contains($0) ? detail.backtrace.images[$0] : nil }
            let table = image?.uuid.flatMap { detail.tables[$0] }
            let frames = table?.frames(offset: index == 0 ? frame.offset : frame.offset &- 1) ?? []

            if let image, !frames.isEmpty {
                isSymbolicated = true
                lines += frames.map { "\(index)   \(image.name)   \($0.text)" }
            } else if fallback.indices.contains(index) {
                lines.append(fallback[index])
            } else {
                lines.append("\(index)   \(image?.name ?? "???")   + 0x\(String(frame.offset, radix: 16))")
            }
        }

        guard isSymbolicated else {
            return nil
        }
        self.lines = lines
    }
}

extension SymbolTable.Frame {
    fileprivate var text: String {
        guard let location else {
            return name
        }
        return "\(name) (\(location.file):\(location.line))"
    }
}
