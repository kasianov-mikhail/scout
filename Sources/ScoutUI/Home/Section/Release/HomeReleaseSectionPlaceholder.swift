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
                SkeletonBar(width: 120, height: 15, delay: 0.96)

                Text(verbatim: "of sessions")
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemGray))
            }

            SkeletonBar(height: 24, delay: 1.04, fill: Color(.systemGray6))
                .padding(.top, 10)

            legend
                .padding(.top, 6)

            SkeletonBar(width: 194, height: 8, delay: 1.12)
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
        .listRowSeparator(.hidden)
    }

    private var legend: some View {
        HStack(spacing: 12) {
            ForEach(Stability.Level.allCases, id: \.self) { level in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(width: 7, height: 7)

                    Text(verbatim: level.title)
                }
            }
        }
        .font(.caption)
        .foregroundStyle(Color(.systemGray))
    }
}
