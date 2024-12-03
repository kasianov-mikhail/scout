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
    @State var period: StatPeriod
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(stat: StatProvider, period: StatPeriod) {
        self.stat = stat
        self._period = State(wrappedValue: period)
    }

    var body: some View {
        VStack {
            PeriodPicker(period: $period)

            if let points = stat.data?[period] {
                List {
                    let count = points.map(\.count).reduce(0, +)

                    chart(points: points).chartBackground { proxy in
                        if count == 0 {
                            Placeholder(text: "No results")
                        }
                    }

                    total(count: count)
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
                x: .value("X", point.date, unit: period.pointComponent),
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
        .aspectRatio(4 / 3, contentMode: .fit)
        .padding()
        .padding(.bottom)
        .listRowInsets(EdgeInsets())
    }

    func total(count: Int) -> some View {
        ZStack {
            HStack {
                Text("Events")
                Spacer()
                Text(count == 0 ? "—" : "\(count)")
            }
            .foregroundColor(.blue)

            NavigationLink {
                StatEventList(eventName: stat.eventName, period: $period)
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
        let stat = StatProvider(eventName: "Event")
        stat.data = data
        return StatView(stat: stat, period: .month)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
