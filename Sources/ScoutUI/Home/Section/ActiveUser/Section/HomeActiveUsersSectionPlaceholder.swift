//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeActiveUsersSectionPlaceholder: View {
    var body: some View {
        Section(title: "Active Users", bottomGap: .space10) {
            ReadoutTabStrip(
                values: ActiveUsers.Kind.allCases,
                isSelected: { _ in false },
                isLoading: true,
                spacing: 0,
                onSelect: nil
            ) { kind, _ in
                metric(kind: kind)
            }

            SkeletonBar(height: 72, delay: 0.56, fill: Color.surfaceGrey)
                .padding(.top, .space12)

            axis

            SkeletonBar(width: 194, height: 8, delay: 0.64)
                .frame(height: 18, alignment: .leading)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }

    private var axis: some View {
        HStack(spacing: 0) {
            SkeletonBar(width: 34, height: 8, delay: 0.64)

            Spacer()

            SkeletonBar(width: 34, height: 8, delay: 0.64)

            Spacer()

            SkeletonBar(width: 34, height: 8, delay: 0.64)
        }
        .frame(height: 12)
        .padding(.top, 6)
    }

    private func metric(kind: ActiveUsers.Kind) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: kind.title.uppercased())
                .font(.scoutCaptionStrong)
                .foregroundStyle(Color.textMuted)

            SkeletonBar(width: 74, height: 17, delay: 0.4)
                .frame(height: 34)

            SkeletonBar(width: 46, height: 8, delay: 0.48)
                .frame(height: 15)
        }
        .padding(.vertical, .space10)
    }
}
