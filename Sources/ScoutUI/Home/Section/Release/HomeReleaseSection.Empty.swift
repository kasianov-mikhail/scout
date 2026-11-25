//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension HomeReleaseSection {
    struct Empty: View {
        let onShowAll: () -> Void

        var body: some View {
            Section(title: "Releases", bottomGap: .space10) {
                HomeSectionExpandButton(action: onShowAll)
                    .accessibilityLabel(Text(verbatim: "Show all releases"))
            } content: {
                HStack(alignment: .center, spacing: .space8) {
                    EmptyBar(width: 150, height: 26, cornerRadius: .radiusBadge)

                    Text(verbatim: "of sessions")
                        .font(.scoutRow)
                        .foregroundStyle(Color.textMuted)
                }
                .frame(height: 28)
                .padding(.top, 14)

                EmptyBar(height: 22, cornerRadius: .radiusBar)
                    .padding(.top, .space10)

                AdoptionLegend(squareSize: 7, squareColor: Color.surfaceBarIdle, dashed: true)
                    .padding(.top, .space8)

                Text(verbatim: "No releases yet")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space10)
                    .padding(.bottom, .space6)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeReleaseSection.Empty {}
            }
        }
        .scrollIndicators(.hidden)
    }
}
