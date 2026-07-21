//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

// Design-exploration primitive: a week strip that expands out of a RangeControl
// bar. Not yet wired into the app.

struct WeekStripCalendar: View {
    var style: CalendarStyle = .capsule

    @State private var expanded = false
    @State private var reference = Date().startOfDay
    @State private var selected = Date().startOfDay

    private var month: CalendarMonth { CalendarMonth(containing: reference) }
    private var week: [CalendarMonth.Day] {
        let first = reference.addingDay(-Calendar.utc.mondayBasedWeekday(from: reference))
        return (0..<7).map { offset in
            let date = first.addingDay(offset)
            return CalendarMonth.Day(
                date: date,
                number: Calendar.utc.component(.day, from: date),
                isCurrentMonth: true
            )
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            control
            if expanded {
                strip
                    .transition(.scale(scale: 0.92, anchor: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
    }

    private var control: some View {
        HStack(spacing: 0) {
            MonthChevron(image: "chevron.left") { reference = reference.addingWeek(-1) }

            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(verbatim: month.shortTitle)
                        .font(.callout)
                        .monospaced()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)

            MonthChevron(image: "chevron.right") { reference = reference.addingWeek(1) }
        }
        .frame(height: 44)
    }

    private var strip: some View {
        HStack(spacing: style.spacing) {
            ForEach(Array(week.enumerated()), id: \.element.id) { index, day in
                cell(day, symbol: CalendarMonth.weekdaySymbols[index])
            }
        }
    }

    private func cell(_ day: CalendarMonth.Day, symbol: String) -> some View {
        let isSelected = day.date == selected
        return VStack(spacing: 6) {
            Text(verbatim: symbol.prefix(1).uppercased())
                .font(.caption2)
                .foregroundStyle(isSelected ? .white : .secondary)
            Text(verbatim: "\(day.number)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background { background(isSelected: isSelected) }
        .onTapGesture { selected = day.date }
    }

    @ViewBuilder
    private func background(isSelected: Bool) -> some View {
        let fill = isSelected ? AnyShapeStyle(.tint) : style.unselectedFill
        switch style {
        case .capsule: Capsule().fill(fill)
        case .cell: RoundedRectangle(cornerRadius: 8).fill(fill)
        }
    }
}

#Preview("Week strip") {
    VStack(spacing: 24) {
        WeekStripCalendar(style: .capsule)
        WeekStripCalendar(style: .cell)
    }
}
