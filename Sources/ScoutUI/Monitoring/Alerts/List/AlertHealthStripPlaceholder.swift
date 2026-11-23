//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertHealthStripPlaceholder: View {
    let delay: Double

    @State private var dimmed = false

    var body: some View {
        AlertHealthStrip(buckets: Array(repeating: .clear, count: 24))
            .opacity(dimmed ? 0.6 : 1)
            .animation(
                .easeInOut(duration: 1.618).repeatForever(autoreverses: true).delay(delay),
                value: dimmed
            )
            .onAppear {
                dimmed = true
            }
    }
}
