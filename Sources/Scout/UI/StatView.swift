//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import CloudKit
import SwiftUI

struct StatView: View {
    let data: ChartData?

    @State var period: StatPeriod
    @EnvironmentObject var tint: Tint

    init(data: ChartData?, period: StatPeriod) {
        self.data = data
        self._period = State(wrappedValue: period)
    }

    var body: some View {
        VStack {
            PeriodPicker(period: $period)

            if let points = data?[period] {
                List {
                    chart(points: points)
                    total(points: points)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            } else {
                ProgressView().tint(nil).frame(maxHeight: .infinity)
            }
        }
        .navigationTitle("Stats")
        .onAppear {
            tint.value = nil
        }
    }

    func chart(points: [ChartPoint]) -> some View {
        Chart(points, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: period.component),
                y: .value("Y", point.count)
            )
            .foregroundStyle(.blue)
        }
        .chartXAxis {
            if period == .month {
                AxisMarks(values: [-28, -21, -14, -7].map(period.range.upperBound.addingDay))
            } else {
                AxisMarks()
            }
        }
        .chartBackground { proxy in
            if points.map(\.count).reduce(0, +) == 0 {
                Placeholder(text: "No results")
            }
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .padding()
        .padding(.bottom)
        .listRowInsets(EdgeInsets())
    }

    func total(points: [ChartPoint]) -> some View {
        ZStack {
            HStack {
                Text("Total")
                Spacer()
                Text("\(points.map(\.count).reduce(0, +))")
            }
            .foregroundColor(.blue)

            NavigationLink {
                StatEventList(period: $period)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        let arrays = StatPeriod.allCases.map { period in
            let points = (0..<30).map { i in
                ChartPoint(
                    date: Date().startOfHour.addingDay(-i),
                    count: Int.random(in: 0...100)
                )
            }

            return (period, points)
        }
        let data = Dictionary(uniqueKeysWithValues: arrays)
        StatView(data: data, period: .month)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
