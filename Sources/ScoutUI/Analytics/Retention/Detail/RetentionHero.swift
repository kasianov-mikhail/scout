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
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let value {
                Text(verbatim: value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
            } else {
                SkeletonBar(width: placeholderWidth, height: 24, delay: 0.08)
                    .frame(height: 40, alignment: .leading)
            }

            Text(verbatim: subtitle)
                .font(.system(size: 17))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.top, 16)
        .padding(.bottom, 14)
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
