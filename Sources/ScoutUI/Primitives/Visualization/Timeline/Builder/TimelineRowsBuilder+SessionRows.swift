//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

extension TimelineRowsBuilder {
    mutating func appendFork(_ session: Session, start: Date, live: Bool) {
        entries.append(
            TimelineEntry(
                id: "fork-\(session.id)",
                kind: .fork,
                height: Self.compactHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: .fork,
                marker: nil,
                title: label("Session", size: 13, weight: .semibold, color: .timelineSessionInk),
                subtitle: sessionSubtitle(session, start: start, live: live).map {
                    label($0, size: 13, weight: .regular, color: .timelineMuted)
                },
                time: start.timelineTime,
                chip: nil,
                tint: nil
            )
        )
    }

    mutating func appendLoop(_ session: Session, start: Date, live: Bool) {
        let subtitle: String
        if live {
            subtitle = "live · " + now.timeIntervalSince(start).timelineDuration
        } else if let end = session.endDate {
            subtitle = "no events · " + end.timeIntervalSince(start).timelineDuration
        } else {
            subtitle = "no events"
        }

        entries.append(
            TimelineEntry(
                id: "loop-\(session.id)",
                kind: .loop,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: .loop(color: .timelineSession),
                marker: nil,
                title: label("Session", size: 13, weight: .semibold, color: .timelineSessionInk),
                subtitle: label(subtitle, size: 13, weight: .regular, color: .timelineMuted),
                time: start.timelineTime,
                chip: nil,
                tint: nil
            )
        )
    }

    mutating func appendCrashMerge(_ crash: Crash, date: Date) {
        entries.append(
            TimelineEntry(
                id: "merge-\(crash.id)",
                kind: .merge,
                height: Self.compactHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 6),
                session: nil,
                connector: .merge(color: .timelineCrash, dashed: false),
                marker: nil,
                title: label("App crashed", size: 13, weight: .semibold, color: .timelineCrashInk),
                subtitle: nil,
                time: date.timelineTime,
                chip: nil,
                tint: nil
            )
        )
    }

    mutating func appendMissingMerge(sessionID: UUID?) {
        entries.append(
            TimelineEntry(
                id: "merge-missing-\(sessionID?.uuidString ?? "")",
                kind: .merge,
                height: Self.compactHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: .merge(color: .timelineSession, dashed: true),
                marker: nil,
                title: label("Session end not recorded", size: 13, weight: .regular, color: .timelineMuted),
                subtitle: nil,
                time: nil,
                chip: nil,
                tint: nil
            )
        )
    }

    private func sessionSubtitle(_ session: Session, start: Date, live: Bool) -> String? {
        if live {
            return "live · " + now.timeIntervalSince(start).timelineDuration
        }
        if let end = session.endDate {
            return end.timeIntervalSince(start).timelineDuration
        }
        return nil
    }
}
