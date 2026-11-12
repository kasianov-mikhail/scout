//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeAlertSectionPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .space6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "ALERTS")
                    .font(.scoutCaptionStrong)

                Spacer()

                SkeletonBar(width: 46, height: 9, delay: 0)
            }

            HStack(spacing: .space2) {
                ForEach(0..<24) { _ in
                    SkeletonBar(height: 10, delay: 0.08, cornerRadius: .radiusBar)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, .space4)

            HStack {
                SkeletonBar(width: 194, height: 9, delay: 0.16)

                Spacer()

                SkeletonBar(width: 46, height: 9, delay: 0.16)
            }
            .frame(height: 16)
            .padding(.top, .space2)
        }
        .padding(.top, .space12)
        .padding(.bottom, .space12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}
