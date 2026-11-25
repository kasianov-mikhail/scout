//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension NetworkEndpointView {
    struct Placeholder: View {
        @Binding var range: NetworkRange
        let ranges: [NetworkRange]

        var body: some View {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $range, ranges: ranges, title: \.detailTitle)
                    .padding(.horizontal, -.gutter)

                NetworkEndpointHeader.Placeholder()

                SectionGap()
                    .padding(.horizontal, -.gutter)

                NetworkLedgerHeader(primary: range.pointComponent.networkTitle)

                ForEach(0..<14, id: \.self) { index in
                    NetworkLedgerRowView.Placeholder(index: index, showsDivider: index < 13)
                }
            }
            .padding(.horizontal, .gutter)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "Loading"))
        }
    }
}
