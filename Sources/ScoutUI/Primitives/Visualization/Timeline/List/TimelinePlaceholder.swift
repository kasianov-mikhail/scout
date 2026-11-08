//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelinePlaceholder: View {
    private let rows = SkeletonRow.samples

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Color.clear.frame(height: 8)

                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    SkeletonRowView(
                        row: row,
                        delay: Double(index) * 0.08,
                        showsSeparator: showsSeparator(after: index)
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func showsSeparator(after index: Int) -> Bool {
        guard rows[index].track == .event, let next = rows[safe: index + 1] else {
            return false
        }
        return next.track == .event
    }
}

#Preview {
    NavigationStack {
        TimelinePlaceholder()
    }
}
