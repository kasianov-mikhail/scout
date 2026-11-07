//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SkeletonBar: View {
    var width: CGFloat?
    let height: CGFloat
    let delay: Double
    var cornerRadius: CGFloat = 3
    var fill = Color(.systemGray5)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dimmed = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(fill)
            .frame(width: width, height: height)
            .opacity(dimmed ? 0.6 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 1.618).repeatForever(autoreverses: true).delay(delay), value: dimmed)
            .onAppear {
                if !reduceMotion {
                    dimmed = true
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 8) {
        SkeletonBar(width: 194, height: 9, delay: 0)
        SkeletonBar(height: 18, delay: 0.1)
        SkeletonBar(width: 46, height: 8, delay: 0.2, fill: Color(.systemGray6))
    }
    .padding()
}
