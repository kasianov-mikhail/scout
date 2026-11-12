//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleasePlaceholder: View {
    let version: String

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                hero
                    .padding(.horizontal, -16)

                grid
                    .padding(.horizontal, -16)

                footer
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var hero: some View {
        HStack(spacing: 16) {
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

            badge
        }
        .padding(.top, 14)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color(.systemGray6))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
        }
    }

    private var badge: some View {
        VStack(spacing: 1) {
            SkeletonBar(width: 46, height: 6, delay: 0.08)
                .frame(height: 12)
            SkeletonBar(width: 28, height: 9, delay: 0.08)
                .frame(height: 16)
        }
        .frame(width: 76, height: 76)
        .overlay {
            Circle()
                .strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
        }
        .rotationEffect(.degrees(-12))
    }

    private var grid: some View {
        let kinds = ReleaseTileValue.Kind.allCases

        return VStack(spacing: 0) {
            ForEach(0..<(kinds.count / 2), id: \.self) { row in
                HStack(spacing: 0) {
                    cell(kind: kinds[row * 2], delay: 0.16 + Double(row) * 0.08, isLeading: true)
                    cell(kind: kinds[row * 2 + 1], delay: 0.16 + Double(row) * 0.08, isLeading: false)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func cell(kind: ReleaseTileValue.Kind, delay: Double, isLeading: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: kind.title)
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))

            SkeletonBar(width: 74, height: 14, delay: delay)
                .frame(height: 29, alignment: .leading)
            SkeletonBar(height: 24, delay: delay, cornerRadius: 4, fill: Color(.systemGray6))
            SkeletonBar(width: 120, height: 6, delay: delay)
                .frame(height: 14, alignment: .leading)
        }
        .releaseGridCell(isLeading: isLeading)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Text(verbatim: "Hang rate")
                .font(.weight450(size: 15))

            Spacer()

            SkeletonBar(width: 74, height: 9, delay: 0.56)
        }
        .frame(height: .rowRegular)
    }
}

#Preview("Release loading") {
    NavigationStack {
        ReleasePlaceholder(version: "3.2.0")
            .navigationTitle(en: "Release")
            .inlineNavigationTitle()
    }
}
