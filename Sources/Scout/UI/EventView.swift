//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct EventView: View {
    let event: Event

    @EnvironmentObject var tint: Tint

    var body: some View {
        let color = event.level?.color

        List {
            EventHeader(event: event)

            if let paramCount = event.paramCount, paramCount > 0 {
                ParamSection(
                    count: paramCount,
                    param: ParamProvider(recordID: event.id)
                )
            }

            StatSection(eventName: event.name)
            HistorySection(event: event)
        }
        .onAppear {
            tint.value = color
        }
        .onDisappear {
            tint.value = nil
        }
        .listStyle(.plain)
        .toolbarBackground(color?.opacity(0.12) ?? .clear, for: .navigationBar)
        .toolbarBackground(color == nil ? .automatic : .visible, for: .navigationBar)
        .navigationTitle(event.name)
    }
}

// MARK: - Header

extension EventView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.y, HH:mm"
        return formatter
    }()

    struct EventHeader: View {
        let event: Event

        var body: some View {
            VStack(alignment: .leading) {
                if let date = event.date {
                    Text(dateFormatter.string(from: date))
                        .font(.system(size: 16))
                        .monospaced()
                }

                Spacer().frame(height: 10)

                if let level = event.level {
                    Group {
                        Text("LEVEL:   ")
                            + Text(level.description.uppercased()).foregroundColor(
                                level.color ?? .blue)
                    }
                    .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Sections

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
            _stat = StateObject(wrappedValue: StatProvider(eventName: eventName))
        }

        var body: some View {
            Header(title: "Stats").task {
                await stat.fetchIfNeeded(in: database)
            }

            ForEach(StatPeriod.allCases) { period in
                ZStack {
                    HStack {
                        Text(period.title).monospaced(false)

                        Spacer()

                        if let count = count(for: period) {
                            Text(count == 0 ? "—" : "\(count)")
                        } else {
                            Redacted(length: 5)
                        }
                    }
                    .foregroundStyle(.blue)

                    NavigationLink {
                        StatView(stat: stat, period: period)
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

        func count(for period: StatPeriod) -> Int? {
            stat.data?[period.pointComponent]?.filter {
                period.range.contains($0.date)
            }
            .map(\.count).reduce(0, +)
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

// MARK: - Title

extension StatPeriod {

    /// A human-readable title for each statistical period.
    fileprivate var title: String {
        switch self {
        case .today:
            "Today"
        case .yesterday:
            "Yesterday"
        case .week:
            "Last 7 days"
        case .month:
            "Last 30 days"
        case .year:
            "Last 365 days"
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        let event = Event(
            name: "event_name",
            level: .info,
            date: Date(),
            paramCount: 3,
            uuid: UUID(),
            id: .init(),
            userID: UUID(),
            sessionID: UUID()
        )
        EventView(event: event)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
