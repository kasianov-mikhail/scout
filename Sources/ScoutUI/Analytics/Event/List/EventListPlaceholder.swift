//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let nameWidths: [CGFloat] = [106, 77, 134, 58]

struct EventListPlaceholder: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(0..<16, id: \.self) { index in
                row(index)
                    .padding(.horizontal, -16)
            }
        }
        .padding(.horizontal, .gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func row(_ index: Int) -> some View {
        let delay = Double(index) * 0.08

        return HStack(spacing: .space10) {
            SkeletonBar(width: 13, height: 13, delay: delay, cornerRadius: .radiusBadge)
                .frame(width: 16, height: 16)

            SkeletonBar(width: nameWidths[index % nameWidths.count], height: 10, delay: delay)
                .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 46, height: 8, delay: delay)
                .frame(width: 68, alignment: .trailing)
        }
        .padding(.horizontal, .gutter)
        .frame(height: .rowRegular)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
                .padding(.leading, 42)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            EventListPlaceholder()
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Events")
    }
}
