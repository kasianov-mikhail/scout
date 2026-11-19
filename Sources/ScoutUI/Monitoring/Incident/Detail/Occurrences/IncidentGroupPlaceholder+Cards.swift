//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension IncidentGroupPlaceholder {
    var cards: some View {
        HStack(alignment: .top, spacing: .space24) {
            ForEach(Array(cardTitles.enumerated()), id: \.offset) { item in
                card(title: item.element)
            }
        }
        .padding(.top, .space20)
        .padding(.bottom, .space18)
        .padding(.horizontal, .gutter)
    }

    private func card(title: String) -> some View {
        VStack(alignment: .leading, spacing: .space4) {
            Text(verbatim: title)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)

            HStack {
                SkeletonBar(width: 46, height: 20, delay: 0.08)

                Spacer()

                SkeletonBar(width: 28, height: 10, delay: 0.08)
            }
            .frame(height: 28)

            SkeletonBar(height: 52, delay: 0.08, cornerRadius: .radiusBadge)
                .padding(.top, .space4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
