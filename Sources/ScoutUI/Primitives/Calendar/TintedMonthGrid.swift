//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct TintedMonthGrid: View {
    let month: CalendarMonth
    @Binding var selection: DateRangeSelection

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(CalendarMonth.weekdaySymbols, id: \.self) { symbol in
                    Text(verbatim: symbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: 4) {
                ForEach(Array(month.weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 4) {
                        ForEach(week) { day in cell(day) }
                    }
                }
            }
        }
    }

    private func cell(_ day: CalendarMonth.Day) -> some View {
        let isEndpoint = selection.isEndpoint(day.date)
        return RoundedRectangle(cornerRadius: 8)
            .fill(fill(day, isEndpoint: isEndpoint))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .overlay {
                Text(verbatim: "\(day.number)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(textStyle(day, isEndpoint: isEndpoint))
            }
            .overlay {
                if month.isToday(day) && !isEndpoint && !selection.contains(day.date) {
                    RoundedRectangle(cornerRadius: 8).stroke(.tint, lineWidth: 1.5)
                }
            }
            .onTapGesture { if day.isCurrentMonth { selection.select(day.date) } }
    }

    private func fill(_ day: CalendarMonth.Day, isEndpoint: Bool) -> Color {
        if isEndpoint {
            return Color.accentColor
        }
        if selection.contains(day.date) {
            return Color.accentColor.opacity(0.25)
        }
        return day.isCurrentMonth ? Color.accentColor.opacity(0.10) : Color(.systemGray6)
    }

    private func textStyle(_ day: CalendarMonth.Day, isEndpoint: Bool) -> AnyShapeStyle {
        if isEndpoint {
            return AnyShapeStyle(.white)
        }
        return day.isCurrentMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }
}
