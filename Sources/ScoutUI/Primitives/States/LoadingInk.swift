//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct LoadingInk: ViewModifier {
    let isLoading: Bool
    var delay: Double = 0

    @State private var isInked = true

    func body(content: Content) -> some View {
        content
            .saturation(isInked ? 1 : 0)
            .animation(.easeOut(duration: 0.3).delay(delay), value: isInked)
            .task(id: isLoading) {
                guard !isLoading else {
                    isInked = false
                    return
                }
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else {
                    return
                }
                isInked = true
            }
    }
}

extension View {
    func loadingInk(isLoading: Bool, delay: Double = 0) -> some View {
        modifier(LoadingInk(isLoading: isLoading, delay: delay))
    }
}

#Preview {
    Text(verbatim: "Ink")
        .loadingInk(isLoading: false)
}
