//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension EventView {
    struct ParamSection: View {
        static let previewLimit = 3

        let count: Int

        @ObservedObject var param: ParamProvider
        @Binding var isParamPresented: Bool
        @Environment(\.database) var database

        var body: some View {
            Header(title: "Params") {
                if let seeAll {
                    SeeAllButton(action: seeAll)
                }
            }
            .task {
                await param.fetchIfNeeded(in: database)
            }

            if let items = try? param.result?.get() {
                ForEach(items.prefix(Self.previewLimit)) { item in
                    ParamRow(item: item)
                }
            } else {
                ForEach(0..<min(Self.previewLimit, count), id: \.self) { _ in
                    ParamRow(item: nil)
                }
            }
        }

        var seeAll: (() -> Void)? {
            if (try? param.result?.get()) != nil, count > Self.previewLimit {
                { isParamPresented = true }
            } else {
                nil
            }
        }
    }
}

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
                    .foregroundStyle(.blue)
                Text(verbatim: "Timeline")
                Spacer()
            } destination: {
                Timeline(deviceID: deviceID, event: event)
            }
        }
    }
}

private struct SeeAllButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: "See all").foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }
}
