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
        InsetList {
            NetworkRangeStrip(selection: $range, ranges: NetworkRange.allCases, title: \.title)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)

            SkeletonBar(width: 160, height: 9, delay: 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .padding(.horizontal, 16)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.separator)
                        .frame(height: 0.5)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            NetworkEndpointListHeader()
                .listRowSeparator(.hidden)

            ForEach(0..<10, id: \.self) { index in
                NetworkEndpointRowPlaceholder(index: index)
                    .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                SkeletonBar(width: 28, height: 9, delay: delay)
                    .frame(width: 56, alignment: .trailing)
                SkeletonBar(width: 28, height: 9, delay: delay)
                    .frame(width: 64, alignment: .trailing)
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            if index < 9 {
                DashedLine()
            }
        }
    }
}
