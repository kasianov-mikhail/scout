//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

private let placeholderWeekdayFormatter = DateFormatter(format: "EEE")
private let placeholderDayLabels = ["S", "M", "T", "W", "T", "F", "S"]

struct DeviceDetailPlaceholder: View {
    let summary: DeviceSummary
    @Binding var range: IncidentRange

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $range, ranges: IncidentRange.allCases, title: \.title)
                    .padding(.top, .space8)

                Text(verbatim: "\(summary.modelName) · \(summary.osVersion) · seen \(summary.lastSeen.relativeString)")
                    .font(.scoutRow)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(2)
                    .padding(.top, .space4)
                    .padding(.bottom, .space12)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }

                stats

                SectionHeader(title: "SESSIONS", topPadding: 12) {
                    Text(verbatim: "TIMELINE")
                        .font(.scoutSectionAction)
                        .foregroundStyle(Color.textLink)
                }

                ForEach(0..<5, id: \.self) { index in
                    sessionRow(index: index)
                }

                Color.clear
                    .frame(height: 8)

                SectionHeader(title: "HISTORY", topPadding: 12)

                ForEach(0..<4, id: \.self) { index in
                    historyRow(index: index, isLast: index == 3)
                }

                Color.clear
                    .frame(height: 12)

                SectionHeader(title: "ACTIVITY", topPadding: 12) {
                    SkeletonBar(width: 74, height: 9, delay: 1.2)
                }

                activity

                VStack(alignment: .leading, spacing: .space8) {
                    SkeletonBar(width: 300, height: 9, delay: 1.36)
                    SkeletonBar(width: 120, height: 9, delay: 1.36)
                }
                .padding(.top, .space12)
                .padding(.bottom, .space16)

                SectionHeader(title: "WHEN IT IS USED", topPadding: 12)

                usage
                    .padding(.top, .space12)

                VStack(alignment: .leading, spacing: .space8) {
                    SkeletonBar(width: 300, height: 9, delay: 1.52)
                    SkeletonBar(width: 120, height: 9, delay: 1.52)
                }
                .padding(.top, .space12)
                .padding(.bottom, .space16)
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat("crashes", divider: true, leading: 0, trailing: 10)
            stat("hangs", divider: true, leading: 10, trailing: 10)
            stat("resources", divider: false, leading: 10, trailing: 0)
        }
        .overlay(alignment: .bottom) {
            Separator()
        }
    }

    private func stat(_ title: String, divider: Bool, leading: CGFloat, trailing: CGFloat) -> some View {
        StatColumn(title: title, leading: leading, trailing: trailing, divider: divider) {
            SkeletonBar(width: 28, height: 18, delay: 0.08)
        }
    }

    private func sessionRow(index: Int) -> some View {
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
            DashedLine()
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
            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, weekday in
                VStack(spacing: .space4) {
                    SkeletonBar(width: 28, height: 6, delay: 1.28)
                    SkeletonBar(height: 56, delay: 1.28, cornerRadius: .radiusBlock, fill: Color.deviceShade)
                        .frame(maxWidth: .infinity)
                    Text(verbatim: weekday.label)
                        .font(weekday.isCurrent ? .system(size: 10, weight: .semibold) : .book(size: 10))
                        .foregroundStyle(weekday.isCurrent ? Color.textPrimary : Color.fillLevel)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, .space12)
    }

    private var usage: some View {
        VStack(spacing: .space2) {
            ForEach(0..<7, id: \.self) { day in
                HStack(spacing: .space6) {
                    Text(verbatim: placeholderDayLabels[day])
                        .font(.book(size: 10))
                        .foregroundStyle(Color.textMuted)
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
                Text(verbatim: "00")
                Spacer()
                Text(verbatim: "06")
                Spacer()
                Text(verbatim: "12")
                Spacer()
                Text(verbatim: "18")
                Spacer()
                Text(verbatim: "23")
            }
            .font(.scoutAxis)
            .foregroundStyle(Color.textMuted)
            .padding(.leading, .gutter)
            .padding(.top, .space2)
        }
    }

    private var weekdays: [PlaceholderWeekday] {
        let today = Date().startOfDay

        return (0..<7).map { index in
            let date = today.addingDay(index - 6)
            return PlaceholderWeekday(label: placeholderWeekdayFormatter.string(from: date), isCurrent: index == 6)
        }
    }
}

private struct PlaceholderWeekday {
    let label: String
    let isCurrent: Bool
}

#Preview("Device loading") {
    NavigationStack {
        DeviceDetailPlaceholder(summary: DeviceSummary.samples[0], range: .constant(.week))
            .navigationTitle(en: "Device")
            .inlineNavigationTitle()
    }
}
