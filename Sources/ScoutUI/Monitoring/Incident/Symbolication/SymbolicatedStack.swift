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
        let frames = detail.attributedFrames
        guard frames.contains(where: { !$0.symbols.isEmpty }) else {
            return nil
        }

        lines = frames.flatMap { frame -> [String] in
            if let image = frame.image, !frame.symbols.isEmpty {
                return frame.symbols.map { "\(frame.index)   \(image.name)   \($0.text)" }
            }
            if fallback.indices.contains(frame.index) {
                return [fallback[frame.index]]
            }
            return ["\(frame.index)   \(frame.image?.name ?? "???")   + 0x\(String(frame.frame.offset, radix: 16))"]
        }
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
