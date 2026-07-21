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

    var body: some View {
        if !frames.isEmpty {
            Header(title: "Stack Trace")

            ForEach(Array(frames.enumerated()), id: \.offset) { _, frame in
                Text(frame)
                    .font(.caption)
                    .monospaced()
                    .lineLimit(2)
            }
        }
    }
}

#Preview {
    InsetList {
        StackTraceSection(frames: [
            "0   CoreFoundation        0x0 __exceptionPreprocess + 164",
            "1   libobjc.A.dylib       0x0 objc_exception_throw + 60",
        ])
    }
}
