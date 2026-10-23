//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct Timeline: View {
    let deviceID: UUID
    var event: Event? = nil
    var highlight: Color = .accentColor

    @Environment(\.database) var database
    @StateObject var provider = TimelineProvider()

    @State private var scope: TimelineScope = .all
    @State private var showLegend = false
    @State private var expandedKind: LegendKind?

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                RingIndicator().frame(maxHeight: .infinity)
            case .failure(let error):
                errorView(Text(verbatim: error.localizedDescription))
            case .success where provider.items.isEmpty:
                errorView(Text(verbatim: "The timeline couldn't be loaded."))
            case .success:
                list
            }
        }
        .navigationTitle(en: "Multi-Rail")
        .inlineNavigationTitle()
        .toolbar {
            if event != nil {
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $scope) {
                        ForEach(TimelineScope.allCases) { scope in
                            Text(verbatim: scope.title).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if showsList {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showLegend.toggle()
                            if !showLegend { expandedKind = nil }
                        }
                    } label: {
                        Image(systemName: showLegend ? "info.circle.fill" : "info.circle")
                    }
                }
            }
        }
        .exportToolbar(text: provider.exportText)
        .task(load)
        .onChange(of: scope) { _ in
            Task(operation: load)
        }
    }

    private var showsList: Bool {
        if case .success = provider.result, !provider.items.isEmpty {
            return true
        }
        return false
    }

    private var list: some View {
        let items = provider.items
        let anchorIndex = event.flatMap { event in items.firstIndex { $0.id == event.id } }

        return TimelineList(
            items: items,
            highlightedID: event?.id,
            highlightColor: highlight,
            older: { RailPagination(lane: provider.older, result: $provider.result) },
            newer: { RailPagination(lane: provider.newer, result: $provider.result) }
        )
        .anchoredScroll(id: anchorIndex.map { items[$0] }, revision: anchorIndex ?? 0)
        .overlay(alignment: .top) {
            if showLegend {
                Legend(kinds: LegendKind.allCases, expanded: $expandedKind)
                    .background(.bar)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func errorView(_ description: Text) -> some View {
        ErrorView(description: description) {
            Task(operation: load)
        }
    }

    private func load() async {
        let feed = TimelineFeed(
            deviceID: deviceID,
            database: database
        )
        await provider.start(
            feed: feed,
            anchorEvent: event,
            eventName: scope == .event ? event?.name : nil
        )
    }
}
