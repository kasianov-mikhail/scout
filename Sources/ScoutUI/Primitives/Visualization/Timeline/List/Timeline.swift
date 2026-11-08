//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct Timeline: View {
    let deviceID: UUID
    let focus: TimelineFocus?

    @Environment(\.database) private var database
    @StateObject var provider: TimelineProvider

    init(deviceID: UUID, focus: TimelineFocus? = nil, provider: TimelineProvider? = nil) {
        self.deviceID = deviceID
        self.focus = focus
        self._provider = StateObject(wrappedValue: provider ?? TimelineProvider())
    }

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                TimelinePlaceholder()
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await load()
                }
            case .success where provider.entries.isEmpty:
                Placeholder(
                    text: "No timeline",
                    systemImage: "calendar.day.timeline.left",
                    description: "Activity appears here once this device reports a launch"
                )
            case .success:
                list.transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isLoading)
        .navigationTitle(en: "Timeline")
        .inlineNavigationTitle()
        .exportToolbar(text: provider.exportText)
        .task(load)
    }

    private var list: some View {
        TimelineList(
            entries: provider.entries,
            focusID: focus?.id,
            older: {
                RailPagination(lane: provider.older, result: $provider.result)
            },
            newer: {
                RailPagination(lane: provider.newer, result: $provider.result)
            }
        )
    }

    private var isLoading: Bool {
        provider.result == nil
    }

    private var anchor: TimelineAnchor? {
        guard let focus else {
            return nil
        }
        return TimelineAnchor(date: focus.date, installID: focus.installID)
    }

    private func load() async {
        guard !ProcessInfo.processInfo.isPreview else {
            return
        }

        await provider.start(
            feed: TimelineFeed(deviceID: deviceID, database: database),
            anchor: anchor,
            focus: focus
        )
    }
}

#Preview("Timeline") {
    let sample = TimelineSample.sample
    let provider = TimelineProvider()
    provider.incidents = sample.incidents
    provider.result = .success(sample.rail)

    return NavigationStack {
        Timeline(deviceID: UUID(), focus: sample.focus, provider: provider)
    }
}

#Preview("Loading") {
    NavigationStack {
        Timeline(deviceID: UUID())
    }
}
