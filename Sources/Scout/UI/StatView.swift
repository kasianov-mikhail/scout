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
    let chartColor: Color
    let showFooter: Bool

    @StateObject var model: StatModel
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(stat: StatProvider, model: StatModel, chartColor: Color = .blue, showFooter: Bool) {
        self.stat = stat
        self._model = StateObject(wrappedValue: model)
        self.chartColor = chartColor
        self.showFooter = showFooter
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(model: model, periods: stat.periods)

            RangeControl(model: model)
                .padding(.top)
                .padding(.horizontal)

            if let points = model.points(from: stat.data) {
                List {
                    chart(points: points).chartBackground { proxy in
                        if points.count == 0 {
                            Placeholder(text: "No results")
                        }
                    }

                    if showFooter {
                        total(count: points.count)
                    }
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
                x: .value("X", point.date, unit: model.period.pointComponent),
                y: .value("Y", point.count)
            )
        }
        .chartXAxis {
            if let axisValues = model.axisValues {
                AxisMarks(values: axisValues)
            } else {
                AxisMarks()
            }
        }
        .listRowSeparator(showFooter ? .visible : .hidden)
        .foregroundStyle(chartColor)
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
                StatEventList(eventName: stat.eventName, range: model.range)
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
        return StatView(stat: stat, period: .month, showFooter: true)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
