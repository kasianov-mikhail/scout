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
            IncidentRangeStrip(selection: $range)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

            SkeletonBar(width: 194, height: 9, delay: 0.08)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .overlay(alignment: .bottom) {
                    separator
                }
                .listRowSeparator(.hidden)

            sectionTitle("OS VERSIONS")
                .listRowSeparator(.hidden)

            SkeletonBar(height: 10, delay: 0.24, cornerRadius: 5, fill: Color.deviceShade)
                .padding(.top, 14)
                .padding(.bottom, 6)
                .listRowSeparator(.hidden)

            ForEach(0..<2, id: \.self) { index in
                osRow(index: index)
                    .listRowSeparator(.hidden)
            }

            sectionTitle("DEVICES", border: false)
                .listRowSeparator(.hidden)

            columns
                .padding(.top, 12)
                .padding(.bottom, 8)
                .overlay(alignment: .bottom) {
                    separator
                }
                .listRowSeparator(.hidden)

            ForEach(0..<11, id: \.self) { index in
                deviceRow(index: index, isLast: index == 10)
                    .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(en: model)
        .inlineNavigationTitle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private func sectionTitle(_ title: String, border: Bool = true) -> some View {
        HStack {
            Text(verbatim: title)
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
        .padding(.top, 12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            if border {
                separator
            }
        }
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
            column("LAST SEEN ↓")
                .frame(width: 84, alignment: .leading)
            column("SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            column("OS")
                .frame(width: 44, alignment: .leading)
            column("CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
        .foregroundStyle(Color(.systemGray))
    }

    private func column(_ title: String) -> some View {
        Text(verbatim: title)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.3)
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
        .frame(minHeight: 40)
        .overlay(alignment: .bottom) {
            if !isLast {
                DashedLine()
            }
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.separator)
            .frame(height: 0.5)
    }
}
