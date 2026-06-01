//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Timeline: View {
    let deviceID: UUID
    var eventName: String? = nil

    @Environment(\.database) var database
    @StateObject private var provider = TimelineProvider()
    @State private var scope: TimelineScope = .event
    @State private var showLegend = false
    @State private var expandedKind: RailKind?

    private var filter: String? {
        scope == .event ? eventName : nil
    }

    var body: some View {
        Group {
            switch provider.result {
            case .idle, .loading:
                ProgressView().frame(maxHeight: .infinity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription), retry: load)
            case .loaded(let rail):
                TimelineList(rail: rail, showLegend: $showLegend, expandedKind: $expandedKind, onLoadMore: loadMore)
            case .paging(let rail):
                TimelineList(rail: rail, showLegend: $showLegend, expandedKind: $expandedKind, isPaging: true)
            case .exhausted(let rail):
                TimelineList(rail: rail, showLegend: $showLegend, expandedKind: $expandedKind)
            }
        }
        .navigationTitle(en: "Multi-Rail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if eventName != nil {
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
        .task {
            await provider.start(deviceID: deviceID, eventName: filter, in: database)
        }
        .onChange(of: scope) { _ in
            Task {
                await provider.reload(deviceID: deviceID, eventName: filter, in: database)
            }
        }
    }

    private func load() {
        Task {
            await provider.start(deviceID: deviceID, eventName: filter, in: database)
        }
    }

    private func loadMore() async {
        await provider.loadMore(in: database)
    }
}
