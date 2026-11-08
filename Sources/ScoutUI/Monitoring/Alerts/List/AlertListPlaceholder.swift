//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertListPlaceholder: View {
    var body: some View {
        InsetList {
            banner

            AlertListLegend(showsAxis: false)
                .padding(.top, 10)
                .frame(minHeight: 44)

            header(delay: 0)
            row(titleWidth: 95, delay: 0, isLast: true)

            header(delay: 0.08)
            row(titleWidth: 69, delay: 0.08, isLast: false)
            row(titleWidth: 120, delay: 0.16, isLast: false)
            row(titleWidth: 52, delay: 0.24, isLast: false)
            row(titleWidth: 95, delay: 0.32, isLast: true)

            header(delay: 0.40)
            row(titleWidth: 69, delay: 0.40, isLast: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var banner: some View {
        HStack(spacing: 12) {
            SkeletonBar(width: 20, height: 20, delay: 0, cornerRadius: 5)

            VStack(alignment: .leading, spacing: 2) {
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

    private func header(delay: Double) -> some View {
        HStack {
            SkeletonBar(width: 46, height: 12, delay: delay)

            Spacer()

            SkeletonBar(width: 28, height: 10, delay: delay)
        }
        .padding(.top, 12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            separator
        }
    }

    private func row(titleWidth: CGFloat, delay: Double, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            SkeletonBar(width: titleWidth, height: 11, delay: delay)
                .frame(height: 19, alignment: .leading)

            HStack {
                SkeletonBar(width: 120, height: 9, delay: delay)

                Spacer()

                SkeletonBar(width: 28, height: 10, delay: delay)
            }
            .frame(height: 16)

            AlertHealthStripPlaceholder(delay: delay)
                .padding(.top, 4)
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            if !isLast {
                separator
            }
        }
        .frame(minHeight: 44)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.separator)
            .frame(height: 0.5)
    }
}

private struct AlertHealthStripPlaceholder: View {
    let delay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dimmed = false

    var body: some View {
        AlertHealthStrip(buckets: Array(repeating: .clear, count: 24))
            .opacity(dimmed ? 0.6 : 1)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 1.618).repeatForever(autoreverses: true).delay(delay),
                value: dimmed
            )
            .onAppear {
                if !reduceMotion {
                    dimmed = true
                }
            }
    }
}

#Preview("Alerts loading") {
    NavigationStack {
        AlertListPlaceholder()
            .navigationTitle(en: "Alerts")
            .inlineNavigationTitle()
    }
}
