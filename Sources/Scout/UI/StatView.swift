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
    @State var period: Period
    @State var range: Range<Date>

    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(stat: StatProvider, period: Period) {
        self.stat = stat
        self._period = State(wrappedValue: period)
        self._range = State(wrappedValue: period.range)
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(
                period: $period,
                accent: period.range != range
            )

            RangeControl(period: period, range: $range)
                .onChange(of: period) { period in
                    range = period.range
                }
                .padding(.top)
                .padding(.horizontal)

            if let points {
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

    var points: [ChartPoint]? {
        stat.data?[period.pointComponent]?.filter {
            range.contains($0.date)
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
                AxisMarks(values: [-28, -21, -14, -7].map(range.upperBound.addingDay))
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
                StatEventList(eventName: stat.eventName, range: range)
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
        let components = Period.all.map(\.pointComponent)
        let arrays = components.map { period in
            let points = (0..<30).map { i in
                ChartPoint(
                    date: Date().startOfHour.addingDay(-i),
                    count: Int.random(in: 0...100)
                )
            }

            return (period, points)
        }
        let data = Dictionary(uniqueKeysWithValues: arrays)
        let stat = StatProvider(eventName: "Event", periods: Period.all)
        stat.data = data
        return StatView(stat: stat, period: .month)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
