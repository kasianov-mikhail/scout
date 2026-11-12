//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let deviceLastSeenWidths: [CGFloat] = [74, 64, 88, 52]

struct ModelDetailPlaceholder: View {
    let model: String
    @Binding var range: IncidentRange

    var body: some View {
        InsetList {
            RangeStrip(selection: $range, ranges: IncidentRange.allCases, title: \.title)
                .padding(.top, 8)

            SkeletonBar(width: 194, height: 9, delay: 0.08)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .overlay(alignment: .bottom) {
                    Separator()
                }

            SectionHeader(title: "OS VERSIONS", topPadding: 12)

            SkeletonBar(height: 10, delay: 0.24, cornerRadius: 5, fill: Color.deviceShade)
                .padding(.top, 14)
                .padding(.bottom, 6)

            ForEach(0..<2, id: \.self) { index in
                osRow(index: index)
            }

            SectionHeader(title: "DEVICES", topPadding: 12, showsSeparator: false)

            columns
                .columnHeaderStyle(topPadding: 12)

            ForEach(0..<11, id: \.self) { index in
                deviceRow(index: index, isLast: index == 10)
            }
        }
        .navigationTitle(en: model)
        .inlineNavigationTitle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func osRow(index: Int) -> some View {
        let delay = 0.32 + Double(index) * 0.08
        let width: CGFloat = index == 0 ? 77 : 56

        return HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray5))
                .frame(width: 8, height: 8)
                .frame(width: 14, alignment: .leading)

            SkeletonBar(width: width, height: 9, delay: delay)
                .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 72, alignment: .trailing)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 56, alignment: .trailing)
        }
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
    }

    private var columns: some View {
        HStack(spacing: 8) {
            ColumnHeader(title: "LAST SEEN ↓")
                .frame(width: 84, alignment: .leading)
            ColumnHeader(title: "SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OS")
                .frame(width: 44, alignment: .leading)
            ColumnHeader(title: "CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
    }

    private func deviceRow(index: Int, isLast: Bool) -> some View {
        let delay = 0.64 + Double(index) * 0.08

        return HStack(spacing: 8) {
            SkeletonBar(width: deviceLastSeenWidths[index % deviceLastSeenWidths.count], height: 9, delay: delay)
                .frame(width: 84, alignment: .leading)

            SkeletonBar(width: 46, height: 9, delay: delay)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 44, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 56, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            if !isLast {
                DashedLine()
            }
        }
    }
}
