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
        InsetList {
            RangeStrip(selection: $range, ranges: IncidentRange.allCases, title: \.title)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

            SkeletonBar(width: 160, height: 9, delay: 0)
                .frame(height: 17.5)
                .padding(.top, 4)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

            IncidentGrid(count: rowCount) { index in
                tile(index: index, side: index.isMultiple(of: 2) ? .leading : .trailing)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func tile(index: Int, side: PlaceholderSide) -> some View {
        let delay = Double(index / 2) * 0.08
        let nameWidth = nameWidths[index % nameWidths.count]

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                SkeletonBar(width: 28, height: 24, delay: delay)
                SkeletonBar(width: 28, height: 10, delay: delay)
            }

            SkeletonBar(width: nameWidth, height: 9, delay: delay)
            SkeletonBar(width: 120, height: 8, delay: delay)
            SkeletonBar(height: 28, delay: delay, cornerRadius: 2, fill: Color(.systemGray6))
                .padding(.top, 4)
        }
        .padding(.top, 16)
        .padding(.bottom, 14)
        .padding(.leading, side == .trailing ? 14 : 0)
        .padding(.trailing, side == .leading ? 14 : 0)
    }
}

#Preview("Crashes loading") {
    NavigationStack {
        IncidentListPlaceholder(range: .constant(.week))
            .navigationTitle(en: "Crashes")
            .inlineNavigationTitle()
    }
}
