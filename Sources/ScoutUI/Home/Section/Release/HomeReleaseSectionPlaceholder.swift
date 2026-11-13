//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSectionPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Releases")

            HStack(alignment: .firstTextBaseline, spacing: .space8) {
                SkeletonBar(width: 120, height: 15, delay: 0.96)

                Text(verbatim: "of sessions")
                    .font(.scoutRow)
                    .foregroundStyle(Color.textMuted)
            }
            .frame(height: 28)

            SkeletonBar(height: 24, delay: 1.04, fill: Color.surfaceGrey)
                .padding(.top, .space10)

            AdoptionLegend(
                squareSize: 7,
                squareColor: Color.surfaceSkeleton,
                captionColor: Color.homeCaption
            )
            .padding(.top, .space8)

            SkeletonBar(width: 194, height: 8, delay: 1.12)
                .frame(height: 18, alignment: .leading)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }
}
