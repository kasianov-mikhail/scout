//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension NetworkLedgerRowView {
    struct Placeholder: View {
        let index: Int
        let showsDivider: Bool

        var body: some View {
            let delay = 0.08 + Double(index) * 0.08

            HStack(spacing: .space8) {
                SkeletonBar(width: 46, height: 9, delay: delay)
                    .frame(width: 58, alignment: .leading)
                SkeletonBar(width: 46, height: 9, delay: delay)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SkeletonBar(width: 28, height: 9, delay: delay)
                    .frame(width: 56, alignment: .trailing)
                SkeletonBar(width: 28, height: 9, delay: delay)
                    .frame(width: 64, alignment: .trailing)
            }
            .frame(height: .rowTable)
            .overlay(alignment: .bottom) {
                if showsDivider {
                    DashedLine()
                }
            }
        }
    }
}
