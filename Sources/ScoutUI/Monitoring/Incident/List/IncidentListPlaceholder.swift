//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let nameWidths: [CGFloat] = [86, 62, 109, 47]
private let rowCount = 8

private enum PlaceholderSide {
    case leading
    case trailing
}

struct IncidentListPlaceholder: View {
    @Binding var range: IncidentRange

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $range, ranges: IncidentRange.allCases, title: \.title)
                    .padding(.top, .space8)

                SkeletonBar(width: 160, height: 9, delay: 0)
                    .frame(height: 17.5)
                    .padding(.top, .space4)
                    .padding(.bottom, .space6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }

                IncidentGrid(count: rowCount) { index in
                    tile(index: index, side: index.isMultiple(of: 2) ? .leading : .trailing)
                }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func tile(index: Int, side: PlaceholderSide) -> some View {
        let delay = Double(index / 2) * 0.08
        let nameWidth = nameWidths[index % nameWidths.count]

        return VStack(alignment: .leading, spacing: .space6) {
            HStack(alignment: .bottom, spacing: .space8) {
                SkeletonBar(width: 28, height: 24, delay: delay)
                SkeletonBar(width: 28, height: 10, delay: delay)
            }
            .frame(height: 34, alignment: .bottom)

            line(size: 13, width: nameWidth, height: 9, delay: delay)
            line(size: 11, width: 120, height: 8, delay: delay)
            SkeletonBar(height: 28, delay: delay, cornerRadius: .radiusBar, fill: Color.surfaceGrey)
                .padding(.top, .space4)
        }
        .padding(.top, .space16)
        .padding(.bottom, .space12)
        .padding(.leading, side == .trailing ? 14 : 0)
        .padding(.trailing, side == .leading ? 14 : 0)
    }

    private func line(size: CGFloat, width: CGFloat, height: CGFloat, delay: Double) -> some View {
        Text(verbatim: " ")
            .font(.book(size: size, design: .monospaced))
            .overlay(alignment: .leading) {
                SkeletonBar(width: width, height: height, delay: delay)
            }
    }
}

#Preview("Crashes loading") {
    NavigationStack {
        IncidentListPlaceholder(range: .constant(.week))
            .navigationTitle(en: "Crashes")
            .inlineNavigationTitle()
    }
}
