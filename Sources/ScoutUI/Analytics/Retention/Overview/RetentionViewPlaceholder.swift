//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionViewPlaceholder: View {
    @Binding var day: RetentionDay

    var body: some View {
        InsetList {
            RetentionHero(subtitle: "people kept", placeholderWidth: 120)
                .frame(minHeight: 44)

            RetentionDayTabs(overview: nil, day: $day)
                .frame(minHeight: 44)

            RetentionSection(title: "Kept per install week", note: "day \(day.rawValue)")

            ForEach(0..<12, id: \.self) { index in
                row(index: index)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func row(index: Int) -> some View {
        let delay = 0.24 + Double(index) * 0.08

        return HStack(spacing: 8) {
            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 52, alignment: .leading)

            SkeletonBar(height: 18, delay: delay, fill: Color(.systemGray6))

            SkeletonBar(width: 74, height: 9, delay: delay)
                .frame(width: 76, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            if index < 11 {
                DashedLine()
            }
        }
    }
}

#Preview("Retention loading") {
    NavigationStack {
        RetentionViewPlaceholder(day: .constant(.day7))
            .navigationTitle(en: "Retention")
            .inlineNavigationTitle()
    }
}
