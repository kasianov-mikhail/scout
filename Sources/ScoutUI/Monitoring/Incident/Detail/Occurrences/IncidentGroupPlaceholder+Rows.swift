//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension IncidentGroupPlaceholder {
    var cardTitles: [String] {
        switch kind {
        case .crash:
            [kind.occurrencesTitle, "DEVICES"]
        case .hang:
            [kind.occurrencesTitle, "LONGEST"]
        case .resource:
            [kind.occurrencesTitle, resourceKind?.peakTitle ?? "PEAK"]
        }
    }

    func affectedRow(title: String, delay: Double) -> some View {
        VStack(alignment: .leading, spacing: .space8) {
            HStack {
                Text(verbatim: title)
                    .font(.scoutRow)

                Spacer()

                SkeletonBar(width: 28, height: 11, delay: delay)
            }

            SkeletonBar(height: 8, delay: delay, cornerRadius: .radiusBadge)

            HStack(spacing: .space12) {
                SkeletonBar(width: 74, height: 9, delay: delay)
                    .matchingLineHeight(.scoutFootnote)
                SkeletonBar(width: 46, height: 9, delay: delay)
                SkeletonBar(width: 46, height: 9, delay: delay)
            }
        }
        .padding(.vertical, .space16)
    }

    var frames: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                let delay = 0.40 + Double(index) * 0.08

                HStack(spacing: .space6) {
                    SkeletonBar(width: 8, height: 9, delay: delay)
                        .frame(width: 18, alignment: .leading)

                    SkeletonBar(width: 74, height: 9, delay: delay)
                        .frame(width: 128, alignment: .leading)

                    SkeletonBar(width: [158, 115, 141, 92, 126, 104][index % 6], height: 9, delay: delay)
                }
                .frame(height: .codeStep)
            }
        }
        .padding(.vertical, .space16)
    }

    func occurrenceRow(index: Int) -> some View {
        let delay = 0.88 + Double(index) * 0.08

        return HStack {
            SkeletonBar(width: 74, height: 11, delay: delay)

            Spacer()

            SkeletonBar(width: 120, height: 9, delay: delay)
        }
        .frame(height: .rowRegular)
    }
}
