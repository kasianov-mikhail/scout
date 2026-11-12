//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeRetentionSectionPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeRetentionHeader()

            ForEach(0..<4) { index in
                row(index: index)
            }

            Text(verbatim: "Gray: installs that week · green: kept")
                .font(.book(size: 13))
                .foregroundStyle(Color(.systemGray))
                .padding(.top, 4)
                .padding(.bottom, 6)
        }
    }

    private func row(index: Int) -> some View {
        let delay = 1.2 + Double(index) * 0.08

        return HStack(spacing: 10) {
            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 56, alignment: .leading)

            SkeletonBar(height: 18, delay: delay)
                .frame(maxWidth: .infinity)
                .padding(.trailing, 4)

            SkeletonBar(width: 46, height: 8, delay: delay)
                .frame(width: 84, alignment: .trailing)
        }
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            if index < 3 {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
        }
    }
}
