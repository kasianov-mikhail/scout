//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension EventView {
    struct ParamSection: View {
        static let previewLimit = 3

        let count: Int

        @Environment(\.database) private var database
        @ObservedObject var param: ParamProvider
        @Binding var isParamPresented: Bool

        var body: some View {
            Header(title: "Params") {
                switch param.result {
                case .success where count > Self.previewLimit:
                    AllButton { isParamPresented = true }
                case .success, .failure, nil:
                    EmptyView()
                }
            }

            switch param.result {
            case .success(let items):
                ForEach(items.prefix(Self.previewLimit)) { item in
                    ParamRow(item: item)
                }
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await param.fetchAgain(in: database)
                }
            case nil:
                ForEach(0..<min(Self.previewLimit, count), id: \.self) { _ in
                    ParamRow(item: nil)
                }
            }
        }
    }
}

extension EventView {
    struct StatSection: View {
        @Environment(\.database) private var database
        @ObservedObject var stat: StatProvider

        var body: some View {
            Header(title: "Stats")

            switch stat.result {
            case .success, nil:
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
                        .largeNavigationTitle()
                    }
                }
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await stat.fetchAgain(in: database)
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
