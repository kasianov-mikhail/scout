//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct OnboardingPage<Accessory: View, Content: View>: View {
    let title: String
    let spacing: CGFloat
    @ViewBuilder let accessory: Accessory
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<3) { _ in Spacer() }

            accessory

            Text(verbatim: title)
                .font(.title)
                .bold()

            content

            ForEach(0..<5) { _ in Spacer() }
        }
    }
}
