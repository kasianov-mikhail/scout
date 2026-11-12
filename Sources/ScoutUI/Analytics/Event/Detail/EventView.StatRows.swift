//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension EventView {
    struct TodayRow: View {
        let stats: EventStats?

        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: .space6) {
                        Text(verbatim: "Today")
                            .font(.scoutRowStrong)

                        Text(verbatim: "so far")
                            .font(.scoutMicro)
                            .foregroundStyle(Color.textMuted)
                    }

                    Spacer()

                    if let stats {
                        CountText(count: stats.today)
                    } else {
                        SkeletonBar(width: 28, height: 11, delay: 0.72)
                    }
                }
                .frame(height: 18)

                Group {
                    if let stats {
                        TodayBar(stats: stats)
                    } else {
                        SkeletonBar(height: 8, delay: 0.72, cornerRadius: .radiusBar, fill: Color.surfaceGrey)
                    }
                }
                .frame(height: 8)
                .padding(.top, .space8)

                HStack {
                    ForEach(Array(hourLabels.enumerated()), id: \.offset) { index, label in
                        if index > 0 {
                            Spacer(minLength: 0)
                        }
                        Text(verbatim: label)
                    }
                }
                .font(.scoutAxis)
                .foregroundStyle(Color.textMuted)
                .padding(.top, .space6)
            }
            .padding(.top, .space10)
            .frame(height: 72, alignment: .top)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }

        private let hourLabels = ["00:00", "06:00", "12:00", "18:00", "24:00"]
    }

    struct TodayBar: View {
        let stats: EventStats

        var body: some View {
            GeometryReader { proxy in
                let width = proxy.size.width

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: .radiusBar)
                        .fill(Color.metricTrack)

                    RoundedRectangle(cornerRadius: .radiusBar)
                        .fill(Color.fillAccent)
                        .frame(width: width * stats.todayBlue)

                    UnevenRoundedRectangle(bottomTrailingRadius: 2, topTrailingRadius: 2)
                        .fill(Color.eventAboveUsual)
                        .frame(width: width * stats.todayAbove)
                        .offset(x: width * stats.dayFraction)

                    Rectangle()
                        .fill(Color.textPrimary)
                        .frame(width: 1.5, height: 16)
                        .offset(x: width * stats.dayFraction - 0.75)
                }
            }
        }
    }

    struct PeriodRow: View {
        let row: EventStats.Row
        let usualFraction: Double

        var body: some View {
            PeriodLayout(title: row.period.title) {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let usualX = width * usualFraction

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: .radiusBar)
                            .fill(Color.metricTrack)
                            .frame(height: 8)

                        UnevenRoundedRectangle(
                            topLeadingRadius: 2,
                            bottomLeadingRadius: 2,
                            bottomTrailingRadius: row.above > 0 ? 0 : 2,
                            topTrailingRadius: row.above > 0 ? 0 : 2
                        )
                        .fill(Color.fillAccent)
                        .frame(width: width * row.blue, height: 8)

                        UnevenRoundedRectangle(bottomTrailingRadius: 2, topTrailingRadius: 2)
                            .fill(Color.eventAboveUsual)
                            .frame(width: width * row.above, height: 8)
                            .offset(x: usualX)

                        VerticalDash()
                            .offset(x: usualX)
                    }
                    .frame(maxHeight: .infinity)
                }
            } value: {
                CountText(count: row.count)
            }
        }
    }

    struct PeriodPlaceholder: View {
        let period: Period
        let delay: Double

        var body: some View {
            PeriodLayout(title: period.title) {
                SkeletonBar(height: 8, delay: delay, cornerRadius: .radiusBar, fill: Color.surfaceGrey)
            } value: {
                SkeletonBar(width: 28, height: 11, delay: delay)
            }
        }
    }

    struct PeriodLayout<Bar: View, Value: View>: View {
        let title: String
        @ViewBuilder let bar: () -> Bar
        @ViewBuilder let value: () -> Value

        var body: some View {
            HStack(spacing: .space8) {
                Text(verbatim: title)
                    .font(.scoutRow)
                    .lineLimit(1)
                    .frame(width: 76, alignment: .leading)

                bar()
                    .frame(maxWidth: .infinity)

                value()
                    .frame(width: 44, alignment: .trailing)
            }
            .frame(height: .rowTable)
            .overlay(alignment: .bottom) {
                DashedLine()
            }
        }
    }

    struct CountText: View {
        let count: Int

        var body: some View {
            Text(verbatim: EventStats.countLabel(count))
                .font(.scoutValue)
                .monospacedDigit()
                .lineLimit(1)
                .foregroundStyle(count == 0 ? Color.lineSeparator : Color.textPrimary)
        }
    }
}
