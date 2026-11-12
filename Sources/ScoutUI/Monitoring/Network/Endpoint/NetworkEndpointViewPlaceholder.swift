//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkEndpointViewPlaceholder: View {
    @Binding var range: NetworkRange
    let ranges: [NetworkRange]

    var body: some View {
        InsetList {
            RangeStrip(selection: $range, ranges: ranges, title: \.detailTitle)
                .padding(.top, 8)
                .padding(.trailing, -16)

            NetworkEndpointHeaderPlaceholder()

            NetworkLedgerHeader(primary: range.pointComponent.networkTitle)

            ForEach(0..<14, id: \.self) { index in
                NetworkLedgerRowPlaceholder(index: index, showsDivider: index < 13)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}

struct NetworkLedgerRowPlaceholder: View {
    let index: Int
    let showsDivider: Bool

    var body: some View {
        let delay = 0.08 + Double(index) * 0.08

        HStack(spacing: 8) {
            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 58, alignment: .leading)
            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(maxWidth: .infinity, alignment: .leading)
            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 56, alignment: .trailing)
            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 64, alignment: .trailing)
        }
        .frame(height: 40)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }
}
