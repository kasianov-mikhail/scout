//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Timeline: View {
    let deviceID: UUID
    var event: Event? = nil

    @Environment(\.database) var database
    @StateObject private var provider = TimelineProvider()

    @State private var scope: TimelineScope = .all
    @State private var showLegend = false
    @State private var expandedKind: LegendKind?

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                ProgressView().frame(maxHeight: .infinity)
            case .failure(let error):
                errorView(for: error)
            case .success(let rail):
                list(for: rail)
            }
        }
        .navigationTitle(en: "Multi-Rail")
        .navigationBarTitleDisplayMode(.inline)
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
        .task(load)
        .onChange(of: scope) { _ in
            Task(operation: load)
        }
    }

    private func list(for rail: Rail) -> some View {
        VStack(spacing: 0) {
            if showLegend {
                Legend(kinds: LegendKind.allCases, expanded: $expandedKind)
            }
            TimelineList(
                items: TimelineItem.items(from: rail),
                highlightedID: event?.id,
                older: { RailPagination(lane: provider.older, result: $provider.result) },
                newer: { RailPagination(lane: provider.newer, result: $provider.result) }
            )
        }
    }

    private func errorView(for error: Error) -> some View {
        ErrorView(description: Text(verbatim: error.localizedDescription)) {
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
            eventName: scope == .event ? event?.name : nil,
        )
    }
}
