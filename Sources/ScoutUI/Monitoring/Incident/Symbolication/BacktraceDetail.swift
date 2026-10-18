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

struct BacktraceDetail: Equatable {
    let backtrace: Backtrace
    let tables: [UUID: SymbolTable]

    static var sample: BacktraceDetail {
        BacktraceDetail(backtrace: .sample, tables: [:])
    }
}

struct SymbolicatedFrame {
    let index: Int
    let frame: Backtrace.Frame
    let image: Backtrace.Image?
    let symbols: [SymbolTable.Frame]
}

extension BacktraceDetail {
    var attributedFrames: [SymbolicatedFrame] {
        guard let thread = backtrace.threads.first(where: \.attributed) else {
            return []
        }
        return thread.frames.enumerated().map { index, frame in
            let image = frame.image.flatMap { backtrace.images.indices.contains($0) ? backtrace.images[$0] : nil }
            let table = image?.uuid.flatMap { tables[$0] }
            let symbols = table?.frames(offset: index == 0 ? frame.offset : frame.offset &- 1) ?? []
            return SymbolicatedFrame(index: index, frame: frame, image: image, symbols: symbols)
        }
    }

    var groupKey: String? {
        guard let first = attributedFrames.first(where: { !$0.symbols.isEmpty }) else {
            return nil
        }
        guard let image = first.image, let function = first.symbols.last else {
            return nil
        }
        return "\(image.name)|\(function.name)"
    }
}
