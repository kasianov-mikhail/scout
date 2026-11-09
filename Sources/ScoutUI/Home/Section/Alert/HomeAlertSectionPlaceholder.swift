//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeAlertSectionPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "ALERTS")
                    .font(.footnote.weight(.semibold))

                Spacer()

                SkeletonText(width: 46, height: 9, font: .footnote.weight(.semibold), delay: 0)
            }

            HStack(spacing: 2) {
                ForEach(0..<24) { _ in
                    SkeletonBar(height: 10, delay: 0.08, cornerRadius: 2)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 4)

            HStack {
                SkeletonText(width: 194, height: 9, font: .weight450(size: 13), delay: 0.16)

                Spacer()

                SkeletonText(width: 46, height: 9, font: .weight450(size: 13), delay: 0.16)
            }
            .padding(.top, 2)
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}
