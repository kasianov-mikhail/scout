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
    struct Config {
        let title: String
        let color: Color
        let showList: Bool
    }

    let config: Config

    @State var model: StatModel
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(config: Config, stat: StatProvider, period: Period) {
        self.config = config
        self.stat = stat
        self._model = State(wrappedValue: StatModel(period: period))
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(model: $model, periods: stat.periods)

            if let points = model.points(from: stat.data) {
                RangeControl(model: $model)
                    .padding(.top)
                    .padding(.horizontal)

                List {
                    chart(points: points).chartBackground { proxy in
                        if points.count == 0 {
                            Placeholder(text: "No results")
                        }
                    }

                    if config.showList {
                        total(count: points.count)
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            } else {
                ProgressView().tint(nil).frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(config.title)
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
        .listRowSeparator(config.showList ? .visible : .hidden)
        .foregroundStyle(config.color)
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

// MARK: - Axis Values

extension StatModel {

    /// Returns the axis values for the chart.
    ///
    /// For a month period, the values are the last 4 weeks. This fixes the issue with the axis
    /// values not being displayed correctly for the month period. For the other periods,
    /// the chart uses default axis values
    ///
    fileprivate var axisValues: [Date]? {
        if period == .month {
            return [-28, -21, -14, -7].map(range.upperBound.addingDay)
        } else {
            return nil
        }
    }
}

// MARK: -

extension StatView.Config: CustomDebugStringConvertible {
    var debugDescription: String {
        "StatView.Configuration(title: \(title), color: \(color), showList: \(showList))"
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
        let config = StatView.Config(title: "Title", color: .blue, showList: true)
        return StatView(config: config, stat: stat, period: .month)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
