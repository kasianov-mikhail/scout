//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

private let latencySkeletonHeights: [CGFloat] = [22, 64, 52, 23, 12, 7, 3]

struct NetworkHourViewPlaceholder: View {
    let date: Date

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ListTitle(title: DateFormatter.networkHourLabel.string(from: date))

                NetworkEndpointHeaderPlaceholder()

                SectionHeader(title: "STATUS")

                SkeletonBar(height: 10, delay: 0.16, cornerRadius: 5)
                    .padding(.top, 14)
                    .padding(.bottom, 6)

                ForEach(0..<3, id: \.self) { index in
                    NetworkStatusRowPlaceholder(index: index)
                }

                SectionHeader(title: "LATENCY")

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(latencySkeletonHeights.indices, id: \.self) { index in
                        VStack(spacing: 4) {
                            SkeletonBar(width: 34, height: latencySkeletonHeights[index], delay: 0.72, cornerRadius: 0)
                            SkeletonBar(width: 24, height: 8, delay: 0.72)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 14)

                HStack(spacing: 16) {
                    SkeletonBar(width: 76, height: 9, delay: 0.8)
                    SkeletonBar(width: 76, height: 9, delay: 0.8)
                    SkeletonBar(width: 76, height: 9, delay: 0.8)
                }
                .padding(.top, 10)
                .padding(.bottom, 14)
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}

private struct NetworkStatusRowPlaceholder: View {
    let index: Int

    var body: some View {
        let delay = 0.24 + Double(index) * 0.08

        HStack(spacing: 8) {
            SkeletonBar(width: 8, height: 8, delay: delay, cornerRadius: 2)
                .frame(width: 14, alignment: .leading)
            SkeletonBar(width: 24, height: 9, delay: delay)
                .frame(width: 44, alignment: .leading)
            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(maxWidth: .infinity, alignment: .leading)
            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 56, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
    }
}
