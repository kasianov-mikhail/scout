//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension TimelineEntry: Fixture {
    static var samples: [TimelineEntry] {
        [
            TimelineEntry(
                id: "install",
                kind: .install,
                height: 44,
                launch: .init(color: .timelinePending, dashed: true, top: 22, bottom: 0),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "arrow.down.to.line", color: .timelineInstall),
                title: .init(text: "App installed", size: 15, weight: .semibold, color: .primary),
                subtitle: .init(text: "Oct 14", size: 13, weight: .regular, color: .timelineMuted),
                time: "10:02",
                chip: nil,
                tint: nil
            ),
            TimelineEntry(
                id: "launch",
                kind: .launch,
                height: 44,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "play.fill", color: .timelineLaunch),
                title: .init(text: "App launched", size: 15, weight: .semibold, color: .primary),
                subtitle: .init(text: "Oct 14 · 2.4.0", size: 13, weight: .regular, color: .timelineMuted),
                time: "10:02",
                chip: nil,
                tint: nil
            ),
            TimelineEntry(
                id: "fork",
                kind: .fork,
                height: 36,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: .fork,
                marker: nil,
                title: .init(text: "Session", size: 13, weight: .semibold, color: .timelineSessionInk),
                subtitle: .init(text: "3m 10s", size: 13, weight: .regular, color: .timelineMuted),
                time: "10:02",
                chip: nil,
                tint: nil
            ),
            TimelineEntry(
                id: "event",
                kind: .event,
                height: 44,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: .init(color: .timelineSession, dashed: false, top: 0, bottom: 0),
                connector: nil,
                marker: .event,
                title: .init(text: "app_open", size: 16, weight: .regular, color: .primary, monospaced: true),
                subtitle: nil,
                time: "10:02:05",
                chip: nil,
                tint: nil,
                showsSeparator: true
            ),
            TimelineEntry(
                id: "crash",
                kind: .crash,
                height: 44,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: .init(
                    color: .timelineSession,
                    dashed: false,
                    top: 0,
                    bottom: 0,
                    split: .init(color: .timelineCrash, y: 22)
                ),
                connector: nil,
                marker: .incident(.crash),
                title: .init(text: "Crash", size: 16, weight: .semibold, color: .timelineCrashInk),
                subtitle: .init(text: "SIGABRT", size: 13, weight: .regular, color: .timelineMuted, monospaced: true),
                time: "10:05:15",
                chip: "This crash",
                tint: Color.timelineCrash.opacity(0.1)
            ),
            TimelineEntry(
                id: "merge",
                kind: .merge,
                height: 36,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 6),
                session: nil,
                connector: .merge(color: .timelineCrash, dashed: false),
                marker: nil,
                title: .init(text: "App crashed", size: 13, weight: .semibold, color: .timelineCrashInk),
                subtitle: nil,
                time: "10:05",
                chip: nil,
                tint: nil
            ),
            TimelineEntry(
                id: "gap",
                kind: .gap,
                height: 36,
                launch: .init(color: .timelinePending, dashed: true, top: 0, bottom: 0),
                session: nil,
                connector: nil,
                marker: nil,
                title: .init(text: "3 h", size: 13, weight: .regular, color: .timelineMuted, italic: true),
                subtitle: nil,
                time: nil,
                chip: nil,
                tint: nil
            ),
        ]
    }
}
