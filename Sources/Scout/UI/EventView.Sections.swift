//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension EventView {
    struct ParamSection: View {
        let count: Int

        @State private var isParamPresented = false

        @StateObject var param: ParamProvider
        @EnvironmentObject var database: DatabaseController

        init(count: Int, param: ParamProvider) {
            self.count = count
            self._param = StateObject(wrappedValue: param)
        }

        var body: some View {
            Header(title: "Params", action: seeAll).task {
                await param.fetchIfNeeded(in: database)
            }
            .navigationDestination(isPresented: $isParamPresented) {
                if let items = param.items {
                    ParamList(items: items)
                }
            }

            if let items = param.items {
                ForEach(items.prefix(3)) { item in
                    ParamRow(item: item)
                }
            } else {
                ForEach(0..<min(3, count), id: \.self) { _ in
                    ParamRow(item: nil)
                }
            }
        }

        var seeAll: (() -> Void)? {
            if param.items == nil, count <= 3 {
                return nil
            } else {
                return { isParamPresented = true }
            }
        }
    }

    struct StatSection: View {
        @StateObject var stat: StatProvider

        @EnvironmentObject var database: DatabaseController

        init(eventName: String) {
            _stat = StateObject(
                wrappedValue: StatProvider(
                    eventName: eventName,
                    periods: Period.all
                )
            )
        }

        var body: some View {
            Header(title: "Stats").task {
                await stat.fetchIfNeeded(in: database)
            }

            ForEach(Period.all) { period in
                ZStack {
                    let model = StatModel(period: period)

                    HStack {
                        Text(period.title).monospaced(false)
                        Spacer()
                        RedactedText(count: model.points(from: stat.data)?.count)
                    }
                    .foregroundStyle(.blue)

                    NavigationLink {
                        StatView(stat: stat, model: model, showFooter: true)
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
    }

    struct HistorySection: View {
        let event: Event

        var body: some View {
            Header(title: "History")

            ForEach(HistoryFilter.Category.allCases) { category in
                row(category: category)
            }
        }

        func row(category: HistoryFilter.Category) -> some View {
            ZStack {
                HStack {
                    Text(category.title).foregroundStyle(.blue)
                    Spacer()
                }

                NavigationLink {
                    if let filter = HistoryFilter(event: event, category: category) {
                        HistoryView(filter: filter)
                    }
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
}
