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

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                SkeletonText(width: 120, height: 15, font: .system(size: 24, weight: .bold), delay: 0.96)

                Text(verbatim: "of sessions")
                    .font(.weight450(size: 15))
                    .foregroundStyle(Color(.systemGray))
            }

            SkeletonBar(height: 24, delay: 1.04, fill: Color(.systemGray6))
                .padding(.top, 10)

            AdoptionLegend(squareSize: 7, squareColor: Color(.systemGray5))
                .padding(.top, 8)

            SkeletonBar(width: 194, height: 8, delay: 1.12)
                .frame(height: 18)
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
    }
}
