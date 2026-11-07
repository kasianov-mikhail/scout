//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

private let stackSymbolWidths: [CGFloat] = [158, 115, 196, 86, 158, 115, 196, 86, 158, 115, 196, 86, 158]

struct IncidentDetailPlaceholder<Element: Incident & IncidentDetailInfo>: View {
    let element: Element
    let group: IncidentGroup<Element>?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                summary
                IncidentDetailHeader(title: "Context")
                IncidentContextRows(element: element, group: group, context: nil, isLoading: true, fullyLoading: true)
                IncidentDetailHeader(title: "Stack Trace") {
                    SkeletonBar(width: 120, height: 9, delay: 0.72)
                }
                stack
            }
            .padding(.horizontal, 16)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 6) {
                SkeletonBar(height: 9, delay: 0.08)
                    .frame(maxWidth: 300)
                SkeletonBar(width: 120, height: 9, delay: 0.16)
            }

            SkeletonBar(width: 120, height: 9, delay: 0.24)

            SkeletonBar(height: 82, delay: 0.32, cornerRadius: 4, fill: Color(.systemGray6))
                .padding(.top, 4)
        }
        .padding(.top, 18)
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private var stack: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(stackSymbolWidths.indices, id: \.self) { index in
                let delay = 0.8 + Double(index) * 0.08
                HStack(spacing: 6) {
                    SkeletonBar(width: 8, height: 9, delay: delay)
                        .frame(width: 18, alignment: .leading)
                    SkeletonBar(width: 74, height: 9, delay: delay)
                        .frame(width: 128, alignment: .leading)
                    SkeletonBar(width: stackSymbolWidths[index], height: 9, delay: delay)
                    Spacer(minLength: 0)
                }
                .frame(height: 16)
            }
        }
        .padding(.vertical, 16)
    }
}
