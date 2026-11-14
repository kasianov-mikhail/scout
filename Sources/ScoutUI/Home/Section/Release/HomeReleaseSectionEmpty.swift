//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSectionEmpty: View {
    let onShowAll: () -> Void

    @Environment(\.homeTypography) private var typography

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Releases", showsSeparator: true, font: typography.font(.section)) {
                HomeSectionExpandButton(label: "Show all releases", action: onShowAll)
            }

            HStack(alignment: .center, spacing: .space8) {
                EmptyBar(width: 150, height: 26, cornerRadius: .radiusBadge)

                Text(verbatim: "of sessions")
                    .homeText(.suffix)
            }
            .frame(height: 28)
            .padding(.top, 14)

            EmptyBar(height: 22, cornerRadius: .radiusBar)
                .padding(.top, .space10)

            AdoptionLegend(
                squareSize: 7,
                squareColor: Color.surfaceBarIdle,
                dashed: true,
                font: typography.font(.legend),
                color: typography.color(.legend)
            )
            .padding(.top, .space8)

            Text(verbatim: "No releases yet")
                .homeText(.caption)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeReleaseSectionEmpty {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
