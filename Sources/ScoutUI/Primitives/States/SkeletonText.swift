//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SkeletonText: View {
    let width: CGFloat
    let height: CGFloat
    let font: Font
    let delay: Double

    var body: some View {
        // Preserve the native line height and baseline of the text being replaced.
        Text(verbatim: "0")
            .font(font)
            .hidden()
            .frame(width: width)
            .overlay {
                SkeletonBar(width: width, height: height, delay: delay)
            }
            .accessibilityHidden(true)
    }
}
