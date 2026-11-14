//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let rowCount = 8

struct ReleaseHealthViewPlaceholder: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            header

            ForEach(0..<rowCount, id: \.self) { index in
                row(index: index)
            }
        }
        .padding(.horizontal, .gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: .space8) {
                SkeletonBar(width: 120, height: 18, delay: 0.08)

                Text(verbatim: "of sessions")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
            .frame(height: 33)

            SkeletonBar(height: 32, delay: 0.08, fill: Color.surfaceGrey)
                .padding(.top, .space12)

            AdoptionLegend(squareSize: 8, squareColor: Color.surfaceSkeleton)
                .padding(.top, .space8)
        }
        .padding(.vertical, .space12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func row(index: Int) -> some View {
        let delay = 0.16 + Double(index) * 0.08

        return HStack(spacing: .space12) {
            Circle()
                .inset(by: 1.5)
                .stroke(Color.surfaceSkeleton, lineWidth: 3)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: .space2) {
                SkeletonBar(width: 46, height: 12, delay: delay)
                    .frame(height: 20, alignment: .leading)

                SkeletonBar(width: 120, height: 9, delay: delay)
                    .frame(height: 15, alignment: .leading)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: .space2) {
                SkeletonBar(width: 46, height: 11, delay: delay)
                    .frame(height: 18, alignment: .trailing)

                SkeletonBar(width: 46, height: 7, delay: delay)
                    .frame(height: 14, alignment: .trailing)
            }
        }
        .frame(height: .rowChart)
        .overlay(alignment: .bottom) {
            if index < rowCount - 1 {
                DashedLine()
            }
        }
    }
}

#Preview("Releases loading") {
    NavigationStack {
        ScrollView {
            ReleaseHealthViewPlaceholder()
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Releases")
        .inlineNavigationTitle()
    }
}
