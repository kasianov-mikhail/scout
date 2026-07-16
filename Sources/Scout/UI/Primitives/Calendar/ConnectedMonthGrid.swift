//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ConnectedMonthGrid: View {
    let month: CalendarMonth
    @Binding var selection: DateRangeSelection

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                ForEach(CalendarMonth.weekdaySymbols, id: \.self) { symbol in
                    Text(verbatim: symbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: 4) {
                ForEach(Array(month.weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        ForEach(Array(week.enumerated()), id: \.element.id) { index, day in
                            cell(day, isFirstColumn: index == 0, isLastColumn: index == week.count - 1)
                        }
                    }
                }
            }
        }
    }

    private func cell(_ day: CalendarMonth.Day, isFirstColumn: Bool, isLastColumn: Bool) -> some View {
        let isEndpoint = selection.isEndpoint(day.date)
        return Text(verbatim: "\(day.number)")
            .font(.callout.monospacedDigit())
            .foregroundStyle(textStyle(day, isEndpoint: isEndpoint))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background { rangeBackground(day, isFirstColumn: isFirstColumn, isLastColumn: isLastColumn) }
            .background {
                if isEndpoint {
                    Circle().fill(.tint).frame(width: 40, height: 40)
                } else if month.isToday(day) && day.isCurrentMonth {
                    Circle().stroke(.tint, lineWidth: 1.5).frame(width: 40, height: 40)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { if day.isCurrentMonth { selection.select(day.date) } }
    }

    @ViewBuilder
    private func rangeBackground(_ day: CalendarMonth.Day, isFirstColumn: Bool, isLastColumn: Bool) -> some View {
        if selection.contains(day.date) {
            let leading = day.date == selection.start || isFirstColumn
            let trailing = day.date == selection.end || isLastColumn
            UnevenRoundedRectangle(
                topLeadingRadius: leading ? 20 : 0,
                bottomLeadingRadius: leading ? 20 : 0,
                bottomTrailingRadius: trailing ? 20 : 0,
                topTrailingRadius: trailing ? 20 : 0
            )
            .fill(Color.accentColor.opacity(0.15))
        }
    }

    private func textStyle(_ day: CalendarMonth.Day, isEndpoint: Bool) -> AnyShapeStyle {
        if isEndpoint {
            return AnyShapeStyle(.white)
        }
        return day.isCurrentMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }
}
