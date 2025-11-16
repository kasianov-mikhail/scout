//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

// MARK: - Param Section

extension EventView {
    struct ParamSection: View {
        let count: Int

        @State private var isParamPresented = false

        @StateObject var param: ParamProvider
        @Environment(\.database) var database

        init(count: Int, param: ParamProvider) {
            self.count = count
            self._param = StateObject(wrappedValue: param)
        }

        var body: some View {
            Header(title: "Params", action: seeAll).task {
                await param.fetchIfNeeded(in: database)
            }
            .navigationDestination(isPresented: $isParamPresented) {
                if let items = try? param.result?.get() {
                    ParamList(items: items)
                }
            }

            if let items = try? param.result?.get() {
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
            if let _ = try? param.result?.get(), count > 3 {
                { isParamPresented = true }
            } else {
                nil
            }
        }
    }
}

// MARK: - Stat Section

extension EventView {
    struct StatSection: View {
        @StateObject var stat: StatProvider

        @Environment(\.database) var database

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
            let statConfig = StatConfig(
                title: "Stats",
                color: .blue,
                showList: true
            )
            ForEach(Period.all) { period in
                StatRow(
                    config: statConfig,
                    period: period,
                    stat: stat
                )
            }
        }
    }
}

// MARK: - History Section

extension EventView {
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
