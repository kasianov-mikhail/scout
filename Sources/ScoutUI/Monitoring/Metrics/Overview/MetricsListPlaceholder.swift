//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsListPlaceholder: View {
    @Binding var range: MetricRange

    private static let nameWidths: [CGFloat] = [77, 56, 98, 42, 77, 56]

    var body: some View {
        InsetList {
            MetricRangeStrip(selection: $range)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)

            grid
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.separator)
                        .frame(height: 0.5)
                }
                .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var grid: some View {
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 0) {
                    tile(index: row * 2, isLeading: true)
                    tile(index: row * 2 + 1, isLeading: false)
                }
            }
        }
    }

    private func tile(index: Int, isLeading: Bool) -> some View {
        let delay = Double(index / 2) * 0.08
        let nameWidth = Self.nameWidths[index % Self.nameWidths.count]

        return VStack(alignment: .leading, spacing: 4) {
            SkeletonBar(width: nameWidth, height: 9, delay: delay)
                .frame(height: 15)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                SkeletonBar(width: 74, height: 20, delay: delay)
                SkeletonBar(width: 28, height: 6, delay: delay)
            }
            .frame(height: 29, alignment: .leading)

            SkeletonBar(height: 28, delay: delay, cornerRadius: 4, fill: Color(.systemGray6))
        }
        .padding(.vertical, 14)
        .padding(.leading, isLeading ? 0 : 12)
        .padding(.trailing, isLeading ? 12 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .trailing) {
            if isLeading {
                Rectangle()
                    .fill(Color.separator)
                    .frame(width: 0.5)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

#Preview("Metrics loading") {
    NavigationStack {
        MetricsListPlaceholder(range: .constant(.today))
            .navigationTitle(en: "Metrics")
            .inlineNavigationTitle()
    }
}
