//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct StackTraceSection: View {
    let frames: [String]
    let caption: String?

    var body: some View {
        if !frames.isEmpty {
            Header(title: "Stack Trace") {
                if let caption {
                    Text(verbatim: caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(Array(frames.enumerated()), id: \.offset) { _, frame in
                Text(frame)
                    .font(.caption)
                    .monospaced()
                    .lineLimit(2)
            }
        }
    }
}

extension StackTraceSection {
    init(frames: [String], caption: String?, detail: BacktraceDetail?) {
        if let detail, let stack = SymbolicatedStack(detail: detail, fallback: frames) {
            self.init(frames: stack.lines, caption: "Symbolicated")
        } else {
            self.init(frames: frames, caption: caption)
        }
    }

    init(crash: Crash, detail: BacktraceDetail?) {
        self.init(
            frames: crash.stackTrace,
            caption: crash.source == .inProcess ? nil : "Unsymbolicated",
            detail: detail
        )
    }
}

#Preview {
    InsetList {
        StackTraceSection(
            frames: [
                "0   CoreFoundation        0x0 __exceptionPreprocess + 164",
                "1   libobjc.A.dylib       0x0 objc_exception_throw + 60",
            ],
            caption: nil
        )
    }
}

#Preview("Unsymbolicated") {
    InsetList {
        StackTraceSection(
            frames: [
                "0   MyApp   + 0x1a2f0",
                "1   UIKitCore   + 0x1388",
            ],
            caption: "Unsymbolicated"
        )
    }
}
