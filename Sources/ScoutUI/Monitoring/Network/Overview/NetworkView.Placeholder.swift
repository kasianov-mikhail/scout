//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension NetworkView {
    struct Placeholder: View {
        @Binding var range: NetworkRange

        var body: some View {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $range, ranges: NetworkRange.allCases, title: \.title)
                    .padding(.horizontal, -.gutter)

                SkeletonBar(width: 160, height: 9, delay: 0)
                    .frame(height: 17.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .space4)
                    .padding(.bottom, .space12)

                SectionGap()
                    .padding(.horizontal, -.gutter)

                NetworkEndpointListHeader()

                ForEach(0..<10, id: \.self) { index in
                    NetworkEndpointRow.Placeholder(index: index)
                }
            }
            .padding(.horizontal, .gutter)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "Loading"))
        }
    }
}
