//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let deviceNameWidths: [CGFloat] = [88, 64, 112, 48]

struct DeviceListPlaceholder: View {
    @Binding var range: IncidentRange

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $range, ranges: IncidentRange.allCases, title: \.title)
                    .padding(.top, 8)

                SkeletonBar(width: 200, height: 9, delay: 0)
                    .frame(height: 17.5, alignment: .leading)
                    .padding(.top, 4)

                columns
                    .columnHeaderStyle()

                ForEach(0..<9, id: \.self) { index in
                    row(index: index, isLast: index == 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var columns: some View {
        HStack(spacing: 8) {
            ColumnHeader(title: "SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OS")
                .frame(width: 112, alignment: .leading)
            ColumnHeader(title: "CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
    }

    private func row(index: Int, isLast: Bool) -> some View {
        let delay = Double(index) * 0.08
        let nameWidth = deviceNameWidths[index % deviceNameWidths.count]

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                SkeletonBar(width: 12, height: 16, delay: delay)
                    .frame(width: 20)

                SkeletonBar(width: nameWidth, height: 9, delay: delay)

                Spacer(minLength: 8)

                SkeletonBar(width: 74, height: 9, delay: delay)
            }

            HStack(spacing: 8) {
                SkeletonBar(width: 34, height: 9, delay: delay)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                SkeletonBar(width: 80, height: 9, delay: delay)
                    .frame(width: 112, alignment: .leading)

                SkeletonBar(width: 12, height: 9, delay: delay)
                    .frame(width: 56, alignment: .trailing)
            }
        }
        .frame(height: .rowChart)
        .overlay(alignment: .bottom) {
            if !isLast {
                DashedLine()
            }
        }
    }
}

#Preview("Devices loading") {
    NavigationStack {
        DeviceListPlaceholder(range: .constant(.week))
            .navigationTitle(en: "Devices")
            .inlineNavigationTitle()
    }
}
