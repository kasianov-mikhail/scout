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
        LazyVStack(alignment: .leading, spacing: 0) {
            hero
                .padding(.horizontal, .gutter)

            RetentionDayTabs(overview: nil, day: $day)
                .padding(.horizontal, .gutter)
                .zIndex(1)

            Section(title: "Kept per install week", note: "day \(day.rawValue)") {
                ForEach(0..<12, id: \.self) { index in
                    row(index: index)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var hero: some View {
        HStack(alignment: .firstTextBaseline, spacing: .space8) {
            SkeletonBar(width: 120, height: 24, delay: 0.08)
                .frame(height: 40, alignment: .leading)
                .alignmentGuide(.firstTextBaseline) { _ in 32 }

            SkeletonBar(width: 74, height: 9, delay: 0.08)
                .frame(height: 21, alignment: .leading)
        }
        .padding(.top, .space16)
        .padding(.bottom, .space12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Separator()
        }
    }

    private func row(index: Int) -> some View {
        let delay = 0.24 + Double(index) * 0.08

        return HStack(spacing: .space8) {
            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 52, alignment: .leading)

            SkeletonBar(height: 18, delay: delay)

            SkeletonBar(width: 74, height: 9, delay: delay)
                .frame(width: 76, alignment: .trailing)
        }
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            if index < 11 {
                DashedLine()
            }
        }
    }
}

#Preview("Retention loading") {
    NavigationStack {
        ScrollView {
            RetentionViewPlaceholder(day: .constant(.day7))
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Retention")
        .inlineNavigationTitle()
    }
}
