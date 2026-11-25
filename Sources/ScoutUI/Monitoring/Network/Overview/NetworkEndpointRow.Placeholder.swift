//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let skeletonPathWidths: [CGFloat] = [172, 125, 218, 94]

extension NetworkEndpointRow {
    struct Placeholder: View {
        let index: Int

        var body: some View {
            let delay = 0.08 + Double(index) * 0.08

            VStack(alignment: .leading, spacing: .space8) {
                HStack(spacing: .space4) {
                    SkeletonBar(width: 28, height: 9, delay: delay)
                    SkeletonBar(width: skeletonPathWidths[index % skeletonPathWidths.count], height: 9, delay: delay)
                }

                HStack(spacing: .space8) {
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
}
