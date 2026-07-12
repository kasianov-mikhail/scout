//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct BenchmarkButton: View {
    let benchmark: @Sendable () async -> Bool
    @Binding var message: Message?

    @State private var isBenchmarking = false

    var body: some View {
        Button {
            isBenchmarking = true
            Task {
                let passed = await benchmark()
                isBenchmarking = false
                message = Message(
                    passed
                        ? "Parallelism limit verified: \(RequestLimiter.requestLimit) in-flight requests hold up."
                        : "Parallelism check failed — see the console log.",
                    level: passed ? .success : .warning
                )
            }
        } label: {
            HStack {
                Text(verbatim: "Run Parallelism Benchmark")
                    .foregroundStyle(.tint)
                if isBenchmarking {
                    Spacer()
                    RingIndicator(size: 22)
                }
            }
        }
        .disabled(isBenchmarking)
    }
}
