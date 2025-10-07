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

    @State var model: ChartModel<Period>
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(config: Config, stat: StatProvider, period: Period) {
        self.config = config
        self.stat = stat
        self._model = State(wrappedValue: ChartModel(period: period))
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(model: $model, periods: stat.periods)

            if let data = stat.data {
                RangeControl(model: $model)
                    .padding(.top)
                    .padding(.horizontal)

                let points = data.points(in: model.viewport)

                List {
                    ChartView(points: points, period: model.period)
                        .foregroundStyle(config.color)
                        .listRowSeparator(config.showList ? .visible : .hidden, edges: .bottom)

                    if config.showList {
                        total(count: points.total)
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

// MARK: -

extension StatView.Config: CustomDebugStringConvertible {
    var debugDescription: String {
        "StatView.Configuration(title: \(title), color: \(color), showList: \(showList))"
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        let stat = StatProvider(eventName: "Event", periods: Period.all)
        stat.data = .sample
        let config = StatView.Config(title: "Title", color: .blue, showList: true)
        return StatView(config: config, stat: stat, period: .month)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
