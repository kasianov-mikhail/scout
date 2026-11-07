//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ReleaseHealthViewPlaceholder: View {
    private let rowCount = 8

    var body: some View {
        List {
            header
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            ForEach(0..<rowCount, id: \.self) { index in
                row(index: index, showsSeparator: index < rowCount - 1)
                    .listRowInsets(.sideInsets)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                SkeletonBar(width: 120, height: 18, delay: 0.08)
                    .frame(height: 34, alignment: .leading)

                Text(verbatim: "of sessions")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }

            SkeletonBar(height: 32, delay: 0.08, cornerRadius: 3, fill: Color(.systemGray6))
                .padding(.top, 12)

            ReleaseLegend(showsColors: false)
                .padding(.top, 8)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Color.separator
                .frame(height: 0.5)
        }
        .padding(.horizontal, 16)
    }

    private func row(index: Int, showsSeparator: Bool) -> some View {
        let delay = 0.16 + Double(index) * 0.08

        return HStack(spacing: 12) {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 3)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 3) {
                SkeletonBar(width: 46, height: 12, delay: delay)
                    .frame(height: 20, alignment: .leading)

                SkeletonBar(width: 120, height: 9, delay: delay)
                    .frame(height: 16, alignment: .leading)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 3) {
                SkeletonBar(width: 46, height: 11, delay: delay)
                    .frame(height: 18, alignment: .trailing)

                SkeletonBar(width: 46, height: 7, delay: delay)
                    .frame(height: 14, alignment: .trailing)
            }
        }
        .frame(minHeight: 64)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                DashedLine()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReleaseHealthViewPlaceholder()
            .navigationTitle(en: "Releases")
            .inlineNavigationTitle()
    }
}
