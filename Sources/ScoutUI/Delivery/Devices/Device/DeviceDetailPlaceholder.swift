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
                    .padding(.top, 8)

                Text(verbatim: "\(summary.modelName) · \(summary.osVersion) · seen \(summary.lastSeen.relativeString)")
                    .font(.weight450(size: 15))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(2)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }

                stats

                SectionHeader(title: "SESSIONS", topPadding: 12) {
                    Text(verbatim: "TIMELINE")
                        .font(.weight450(size: 16))
                        .foregroundStyle(.blue)
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

                VStack(alignment: .leading, spacing: 8) {
                    SkeletonBar(width: 300, height: 9, delay: 1.36)
                    SkeletonBar(width: 120, height: 9, delay: 1.36)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)

                SectionHeader(title: "WHEN IT IS USED", topPadding: 12)

                usage
                    .padding(.top, 14)

                VStack(alignment: .leading, spacing: 8) {
                    SkeletonBar(width: 300, height: 9, delay: 1.52)
                    SkeletonBar(width: 120, height: 9, delay: 1.52)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
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

        return HStack(spacing: 8) {
            Circle()
                .fill(Color.clear)
                .frame(width: 8, height: 8)

            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 76, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .padding(.leading, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            SkeletonBar(width: 28, height: 9, delay: delay)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
    }

    private func historyRow(index: Int, isLast: Bool) -> some View {
        let delay = 0.8 + Double(index) * 0.08
        let widths: [CGFloat] = [88, 64, 112, 48]

        return HStack(spacing: 12) {
            ZStack {
                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .offset(y: 22)
                }

                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 8, height: 8)
            }
            .frame(width: 8, height: 44)

            SkeletonBar(width: 46, height: 9, delay: delay)
                .frame(width: 56, alignment: .leading)

            SkeletonBar(width: widths[index], height: 9, delay: delay)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 44)
    }

    private var activity: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, weekday in
                VStack(spacing: 4) {
                    SkeletonBar(width: 28, height: 6, delay: 1.28)
                    SkeletonBar(height: 56, delay: 1.28, cornerRadius: 3, fill: Color.deviceShade)
                        .frame(maxWidth: .infinity)
                    Text(verbatim: weekday.label)
                        .font(weekday.isCurrent ? .system(size: 11, weight: .semibold) : .weight450(size: 11))
                        .foregroundStyle(weekday.isCurrent ? Color.primary : Color(.systemGray))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 14)
    }

    private var usage: some View {
        VStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { day in
                HStack(spacing: 6) {
                    Text(verbatim: placeholderDayLabels[day])
                        .font(.weight450(size: 10))
                        .foregroundStyle(Color(.systemGray))
                        .frame(width: 10, alignment: .leading)

                    HStack(spacing: 2) {
                        ForEach(0..<24, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2)
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
            .font(.weight450(size: 10, design: .monospaced))
            .foregroundStyle(Color(.systemGray))
            .padding(.leading, 16)
            .padding(.top, 3)
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
