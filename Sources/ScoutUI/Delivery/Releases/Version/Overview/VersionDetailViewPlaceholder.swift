//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct VersionDetailViewPlaceholder: View {
    let version: String

    var body: some View {
        List {
            header
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            grid
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            hangRate
                .listRowInsets(.sideInsets)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: version)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .tracking(-0.5)

                SkeletonBar(width: 200, height: 9, delay: 0.08)
                    .frame(height: 18, alignment: .leading)

                SkeletonBar(width: 120, height: 9, delay: 0.08)
                    .frame(height: 18, alignment: .leading)
            }

            Spacer(minLength: 0)

            stamp
        }
        .padding(EdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .overlay(alignment: .bottom) {
            Color(.systemGray5)
                .frame(height: 0.5)
        }
    }

    private var stamp: some View {
        VStack(spacing: 0) {
            SkeletonBar(width: 46, height: 6, delay: 0.08)
                .frame(height: 12)

            SkeletonBar(width: 28, height: 9, delay: 0.08)
                .frame(height: 16)
        }
        .frame(width: 76, height: 76)
        .overlay {
            Circle()
                .strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
        }
        .rotationEffect(.degrees(-12))
    }

    private var grid: some View {
        let metrics = VersionMetric.allCases

        return VStack(spacing: 0) {
            ForEach(Array(stride(from: 0, to: metrics.count, by: 2)), id: \.self) { index in
                HStack(alignment: .top, spacing: 0) {
                    tile(metric: metrics[index], index: index, leading: true)

                    if index + 1 < metrics.count {
                        tile(metric: metrics[index + 1], index: index + 1, leading: false)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func tile(metric: VersionMetric, index: Int, leading: Bool) -> some View {
        let delay = 0.16 + Double(index / 2) * 0.08

        return VersionMetricCell(title: metric.title, leading: leading) {
            VStack(alignment: .leading, spacing: 6) {
                SkeletonBar(width: 74, height: 14, delay: delay)
                    .frame(height: 28, alignment: .leading)

                SkeletonBar(height: 24, delay: delay, cornerRadius: 4, fill: Color(.systemGray6))

                SkeletonBar(width: 120, height: 6, delay: delay)
                    .frame(height: 14, alignment: .leading)
            }
        }
    }

    private var hangRate: some View {
        HStack(spacing: 8) {
            Text(verbatim: "Hang rate")
                .font(.system(size: 15))

            Spacer()

            SkeletonBar(width: 74, height: 9, delay: 0.56)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    NavigationStack {
        VersionDetailViewPlaceholder(version: "3.2.0")
            .navigationTitle(en: "Release")
            .inlineNavigationTitle()
            .toolbarBackground(Color(.systemGray6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
