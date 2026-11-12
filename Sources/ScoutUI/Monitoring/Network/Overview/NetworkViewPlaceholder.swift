//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let skeletonPathWidths: [CGFloat] = [172, 125, 218, 94]

struct NetworkViewPlaceholder: View {
    @Binding var range: NetworkRange

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $range, ranges: NetworkRange.allCases, title: \.title)
                    .padding(.top, 8)
                    .padding(.trailing, -16)

                SkeletonBar(width: 160, height: 9, delay: 0)
                    .frame(height: 17.5, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 16)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                    .padding(.horizontal, -16)

                NetworkEndpointListHeader()

                ForEach(0..<10, id: \.self) { index in
                    NetworkEndpointRowPlaceholder(index: index)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}

struct NetworkEndpointRowPlaceholder: View {
    let index: Int

    var body: some View {
        let delay = 0.08 + Double(index) * 0.08

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                SkeletonBar(width: 28, height: 9, delay: delay)
                SkeletonBar(width: skeletonPathWidths[index % skeletonPathWidths.count], height: 9, delay: delay)
            }

            HStack(spacing: 8) {
                SkeletonBar(width: 46, height: 9, delay: delay)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SkeletonBar(width: 28, height: 9, delay: delay)
                    .frame(width: 56, alignment: .trailing)
                SkeletonBar(width: 28, height: 9, delay: delay)
                    .frame(width: 64, alignment: .trailing)
            }
        }
        .frame(height: .rowChart)
        .overlay(alignment: .bottom) {
            if index < 9 {
                DashedLine()
            }
        }
    }
}
