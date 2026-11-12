//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionHero: View {
    let value: String?
    let subtitle: String
    let placeholderWidth: CGFloat

    init(value: String, subtitle: String) {
        self.value = value
        self.subtitle = subtitle
        self.placeholderWidth = 0
    }

    init(subtitle: String, placeholderWidth: CGFloat) {
        self.value = nil
        self.subtitle = subtitle
        self.placeholderWidth = placeholderWidth
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: .space8) {
            if let value {
                Text(verbatim: value)
                    .font(.scoutNumberXL)
                    .monospacedDigit()
                    .frame(height: 40, alignment: .leading)
            } else {
                SkeletonBar(width: placeholderWidth, height: 24, delay: 0.08)
                    .frame(height: 40, alignment: .leading)
                    .alignmentGuide(.firstTextBaseline) { _ in 32 }
            }

            Text(verbatim: subtitle)
                .font(.scoutBody)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.top, .space16)
        .padding(.bottom, .space12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    VStack {
        RetentionHero(value: "1,168", subtitle: "people kept")
        RetentionHero(subtitle: "people kept", placeholderWidth: 120)
    }
}
