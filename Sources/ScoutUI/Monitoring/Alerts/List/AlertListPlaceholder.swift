//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertListPlaceholder: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            banner
                .padding(.horizontal, .gutter)

            legend
                .padding(.top, .space10)
                .padding(.horizontal, .gutter)

            Section(title: "Firing", bottomGap: .space6) {
                SkeletonBar(width: 28, height: 10, delay: 0)
            } content: {
                row(titleWidth: 95, delay: 0, isLast: true)
            }

            Section(title: "Armed", bottomGap: .space6) {
                SkeletonBar(width: 28, height: 10, delay: 0.08)
            } content: {
                row(titleWidth: 69, delay: 0.08, isLast: false)
                row(titleWidth: 120, delay: 0.16, isLast: false)
                row(titleWidth: 52, delay: 0.24, isLast: false)
                row(titleWidth: 95, delay: 0.32, isLast: true)
            }

            Section(title: "Muted", bottomGap: .space6) {
                SkeletonBar(width: 28, height: 10, delay: 0.40)
            } content: {
                row(titleWidth: 69, delay: 0.40, isLast: true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: .space4) {
            HStack(spacing: 0) {
                SkeletonBar(width: 34, height: 8, delay: 0)

                Spacer()

                SkeletonBar(width: 34, height: 8, delay: 0)

                Spacer()

                SkeletonBar(width: 34, height: 8, delay: 0)
            }
            .frame(height: 12)

            HStack(spacing: .space12) {
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: .space4) {
                        SkeletonBar(width: 10, height: 10, delay: 0, cornerRadius: .radiusBar)

                        SkeletonBar(width: 40, height: 8, delay: 0)
                    }
                }
            }
            .frame(height: 14, alignment: .leading)
        }
        .padding(.bottom, .space16)
    }

    private var banner: some View {
        HStack(spacing: .space12) {
            SkeletonBar(width: 20, height: 20, delay: 0, cornerRadius: .radiusBadge)

            VStack(alignment: .leading, spacing: .space2) {
                SkeletonBar(width: 120, height: 11, delay: 0)
                SkeletonBar(width: 74, height: 9, delay: 0)
            }

            Spacer(minLength: 0)

            SkeletonBar(width: 46, height: 11, delay: 0)
        }
        .frame(height: 60)
        .overlay(alignment: .bottom) {
            separator
        }
    }

    private func row(titleWidth: CGFloat, delay: Double, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: .space6) {
            SkeletonBar(width: titleWidth, height: 11, delay: delay)
                .frame(height: 19)

            HStack {
                SkeletonBar(width: 120, height: 9, delay: delay)

                Spacer()

                SkeletonBar(width: 28, height: 10, delay: delay)
            }
            .frame(height: 16)

            AlertHealthStripPlaceholder(delay: delay)
                .padding(.top, .space4)
        }
        .padding(.top, .space12)
        .padding(.bottom, .space12)
        .overlay(alignment: .bottom) {
            if !isLast {
                separator
            }
        }
    }

    private var separator: some View {
        Separator()
    }
}

#Preview("Alerts loading") {
    NavigationStack {
        ScrollView {
            AlertListPlaceholder()
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Alerts")
        .inlineNavigationTitle()
    }
}
