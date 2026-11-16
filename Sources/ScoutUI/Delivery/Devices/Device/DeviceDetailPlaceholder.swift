//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DeviceDetailPlaceholder: View {
    @Binding var range: IncidentRange

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $range, ranges: IncidentRange.allCases, title: \.title)
                .padding(.top, .space8)
                .padding(.horizontal, .gutter)

            SkeletonBar(width: 194, height: 9, delay: 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 18, alignment: .leading)
                .padding(.top, .space4)
                .padding(.bottom, .space12)
                .padding(.horizontal, .gutter)
                .overlay(alignment: .bottom) {
                    Separator()
                        .padding(.horizontal, .gutter)
                }

            stats
                .padding(.horizontal, .gutter)

            Section(title: "Sessions") {
                Text(verbatim: "TIMELINE")
                    .font(.scoutSectionAction)
                    .foregroundStyle(Color.textLink)
            } content: {
                ForEach(0..<5, id: \.self) { index in
                    sessionRow(index: index, showsDivider: index < 4)
                }
            }

            Section(title: "History") {
                ForEach(0..<4, id: \.self) { index in
                    historyRow(index: index, isLast: index == 3)
                }
            }

            Section(title: "Activity", bottomGap: 0) {
                SkeletonBar(width: 74, height: 9, delay: 1.2)
            } content: {
                activity

                VStack(alignment: .leading, spacing: .space8) {
                    SkeletonBar(width: 300, height: 9, delay: 1.36)
                    SkeletonBar(width: 120, height: 9, delay: 1.36)
                }
                .padding(.top, .space12)
                .padding(.bottom, .space16)
            }

            Section(title: "When it is used", bottomGap: 0) {
                usage
                    .padding(.top, .space12)

                VStack(alignment: .leading, spacing: .space8) {
                    SkeletonBar(width: 300, height: 9, delay: 1.52)
                    SkeletonBar(width: 120, height: 9, delay: 1.52)
                }
                .padding(.top, .space12)
                .padding(.bottom, .space16)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat(divider: true, leading: 0, trailing: 10)
            stat(divider: true, leading: 10, trailing: 10)
            stat(divider: false, leading: 10, trailing: 0)
        }
        .padding(.bottom, .space6)
    }

    private func stat(divider: Bool, leading: CGFloat, trailing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            SkeletonBar(width: 28, height: 18, delay: 0.08)

            SkeletonBar(width: 40, height: 7, delay: 0.08)
                .frame(height: 16, alignment: .leading)
        }
        .padding(.vertical, .space12)
        .padding(.leading, leading)
        .padding(.trailing, trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if divider {
                Separator(axis: .vertical)
            }
        }
    }

    private func sessionRow(index: Int, showsDivider: Bool) -> some View {
        let delay = 0.24 + Double(index) * 0.08

        return HStack(spacing: .space8) {
            Circle()
                .fill(Color.clear)
                .frame(width: 8, height: 8)

            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 76, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .padding(.leading, .space4)
                .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 44, alignment: .trailing)
        }
        .frame(height: .rowRegular)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }

    private func historyRow(index: Int, isLast: Bool) -> some View {
        let delay = 0.8 + Double(index) * 0.08
        let widths: [CGFloat] = [88, 64, 112, 48]

        return HStack(spacing: .space12) {
            ZStack {
                if !isLast {
                    Rectangle()
                        .fill(Color.surfaceBarIdle)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .offset(y: 22)
                }

                Circle()
                    .fill(Color.surfaceSkeleton)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 8, height: 44)

            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 56, alignment: .leading)

            SkeletonBar(width: widths[index], height: 9, delay: delay)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: .rowRegular)
    }

    private var activity: some View {
        HStack(alignment: .bottom, spacing: .space6) {
            ForEach(0..<7, id: \.self) { _ in
                VStack(spacing: .space4) {
                    SkeletonBar(width: 28, height: 6, delay: 1.28)
                    SkeletonBar(height: 56, delay: 1.28, cornerRadius: .radiusBlock, fill: Color.deviceShade)
                        .frame(maxWidth: .infinity)
                    SkeletonBar(width: 24, height: 6, delay: 1.28)
                        .frame(height: 12, alignment: .center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, .space12)
    }

    private var usage: some View {
        VStack(spacing: .space2) {
            ForEach(0..<7, id: \.self) { _ in
                HStack(spacing: .space6) {
                    SkeletonBar(width: 8, height: 6, delay: 1.52)
                        .frame(width: 10, alignment: .leading)

                    HStack(spacing: .space2) {
                        ForEach(0..<24, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: .radiusBar)
                                .fill(Color.deviceShade)
                                .frame(height: 12)
                        }
                    }
                }
            }

            HStack(spacing: 0) {
                SkeletonBar(width: 20, height: 6, delay: 1.52)
                Spacer()
                SkeletonBar(width: 20, height: 6, delay: 1.52)
                Spacer()
                SkeletonBar(width: 20, height: 6, delay: 1.52)
                Spacer()
                SkeletonBar(width: 20, height: 6, delay: 1.52)
                Spacer()
                SkeletonBar(width: 20, height: 6, delay: 1.52)
            }
            .frame(height: 12)
            .padding(.leading, .gutter)
            .padding(.top, .space2)
        }
    }
}

#Preview("Device loading") {
    NavigationStack {
        ScrollView {
            DeviceDetailPlaceholder(range: .constant(.week))
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Device")
        .inlineNavigationTitle()
    }
}
