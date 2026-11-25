//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension HomeReleaseSection {
    struct Placeholder: View {
        var body: some View {
            Section(title: "Releases", bottomGap: .space10) {
                HStack(alignment: .firstTextBaseline, spacing: .space8) {
                    SkeletonBar(width: 120, height: 15, delay: 0.96)

                    SkeletonBar(width: 74, height: 9, delay: 0.96)
                        .frame(height: 18, alignment: .leading)
                }
                .frame(height: 28)
                .padding(.top, 14)

                SkeletonBar(height: 24, delay: 1.04)
                    .padding(.top, .space10)

                legend
                    .padding(.top, .space8)

                SkeletonBar(width: 194, height: 8, delay: 1.12)
                    .matchingLineHeight(.scoutCaption)
                    .padding(.top, .space10)
                    .padding(.bottom, .space6)
            }
        }

        private var legend: some View {
            HStack(spacing: .space12) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack(spacing: .space4) {
                        SkeletonBar(width: 7, height: 7, delay: 1.08, cornerRadius: .radiusBar)

                        SkeletonBar(width: 34, height: 7, delay: 1.08)
                            .matchingLineHeight(.scoutFootnote)
                    }
                }
            }
        }
    }
}
