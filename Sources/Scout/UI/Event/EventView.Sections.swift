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

        @ObservedObject var param: ParamProvider
        @Binding var isParamPresented: Bool
        @Environment(\.database) var database

        var body: some View {
            Header(title: "Params", action: seeAll).task {
                await param.fetchIfNeeded(in: database)
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
            if (try? param.result?.get()) != nil, count > 3 {
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
                    periods: Period.allCases
                )
            )
        }

        var body: some View {
            Header(title: "Stats").task {
                await stat.fetchIfNeeded(in: database)
            }
            ForEach(Period.allCases) { period in
                StatRow(
                    color: .blue,
                    period: period,
                    systemImage: "calendar",
                    stat: stat
                ) {
                    StatView(
                        showList: true,
                        extent: ChartExtent(period: period),
                        stat: stat
                    )
                    .navigationTitle(en: "Stats")
                }
            }
        }
    }
}

// MARK: - History Section

extension EventView {
    struct HistorySection: View {
        let event: Event

        var body: some View {
            if let deviceID = event.deviceID {
                Header(title: "History")
                timelineRow(deviceID: deviceID)
            }
        }

        func timelineRow(deviceID: UUID) -> some View {
            Row {
                Image(systemName: "calendar.day.timeline.left")
                    .frame(width: 24)
                Text(verbatim: "Timeline")
                Spacer()
            } destination: {
                Timeline(deviceID: deviceID, event: event)
            }
            .foregroundStyle(.blue)
        }
    }
}
