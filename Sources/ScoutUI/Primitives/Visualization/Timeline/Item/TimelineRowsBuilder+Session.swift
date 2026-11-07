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
    mutating func appendSession(_ root: SessionRoot, isLast: Bool, live: Bool) {
        guard let start = root.session.startDate else {
            return
        }

        let sessionID = root.session.sessionID
        let crashes = sessionID.flatMap { crashesBySession[$0] } ?? []
        let hangs = sessionID.flatMap { hangsBySession[$0] } ?? []
        let resources = sessionID.flatMap { resourcesBySession[$0] } ?? []
        let occurrences = occurrences(events: root.events, crashes: crashes, hangs: hangs, resources: resources)
        let sessionLive = live && isLast && root.session.endDate == nil && crashes.isEmpty

        if occurrences.isEmpty {
            appendLoop(root.session, start: start, live: sessionLive)
            return
        }

        appendFork(root.session, start: start, live: sessionLive)

        for (index, occurrence) in occurrences.enumerated() {
            appendOccurrence(occurrence, isLast: index == occurrences.count - 1)
        }

        if case .crash(let crash)? = occurrences.last, let date = crash.date {
            appendCrashMerge(crash, date: date)
        } else if root.session.endDate == nil && !sessionLive {
            appendMissingMerge(sessionID: sessionID)
        }
    }

    private func occurrences(events: [Event], crashes: [Crash], hangs: [Hang], resources: [ResourceException]) -> [Occurrence] {
        var occurrences: [Occurrence] = []

        for event in events where event.date != nil {
            occurrences.append(.event(event))
        }
        for crash in crashes where crash.date != nil {
            occurrences.append(.crash(crash))
        }
        for hang in hangs where hang.date != nil {
            occurrences.append(.hang(hang))
        }
        for resource in resources where resource.date != nil {
            occurrences.append(.resource(resource))
        }

        return occurrences.sorted { $0.date < $1.date }
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

    private mutating func appendFork(_ session: Session, start: Date, live: Bool) {
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

    private mutating func appendLoop(_ session: Session, start: Date, live: Bool) {
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

    private mutating func appendCrashMerge(_ crash: Crash, date: Date) {
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

    private mutating func appendMissingMerge(sessionID: UUID?) {
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
}

extension TimelineRowsBuilder {
    private mutating func appendOccurrence(_ occurrence: Occurrence, isLast: Bool) {
        switch occurrence {
        case .event(let event):
            appendEvent(event)
        case .crash(let crash):
            appendIncident(
                id: crash.id,
                kind: .crash,
                date: crash.date,
                title: "Crash",
                subtitle: crash.name,
                incidentKind: .crash,
                closesSession: isLast
            )
        case .hang(let hang):
            appendIncident(
                id: hang.id,
                kind: .hang,
                date: hang.date,
                title: "Hang",
                subtitle: hang.duration.duration,
                incidentKind: .hang
            )
        case .resource(let resource):
            appendIncident(
                id: resource.id,
                kind: .resource,
                date: resource.date,
                title: resource.name,
                subtitle: resource.reason,
                incidentKind: .resource
            )
        }
    }

    private mutating func appendEvent(_ event: Event) {
        guard let date = event.date else {
            return
        }

        let focused = focus?.id == event.id

        entries.append(
            TimelineEntry(
                id: event.id,
                kind: .event,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: TimelineEntry.Lane(color: .timelineSession, dashed: false, top: 0, bottom: 0),
                connector: nil,
                marker: .event,
                title: label(event.name, size: 16, weight: .regular, color: .primary, monospaced: true),
                subtitle: nil,
                time: date.timelineSecond,
                chip: nil,
                tint: focused ? Color.accentColor.opacity(0.12) : nil
            )
        )
    }

    private mutating func appendIncident(id: String, kind: TimelineEntry.Kind, date: Date?, title: String, subtitle: String?, incidentKind: IncidentKind, closesSession: Bool = false) {
        guard let date else {
            return
        }

        let focused = focus?.id == id

        entries.append(
            TimelineEntry(
                id: id,
                kind: kind,
                height: Self.rowHeight,
                launch: TimelineEntry.Lane(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: TimelineEntry.Lane(
                    color: .timelineSession,
                    dashed: false,
                    top: 0,
                    bottom: 0,
                    split: closesSession ? .init(color: .timelineCrash, y: Self.rowHeight / 2) : nil
                ),
                connector: nil,
                marker: .incident(incidentKind),
                title: label(title, size: 16, weight: .semibold, color: incidentKind.timelineInk),
                subtitle: subtitle.map {
                    label($0, size: 13, weight: .regular, color: .timelineMuted, monospaced: true)
                },
                time: date.timelineSecond,
                chip: focused ? focus?.chip : nil,
                tint: focused ? incidentKind.timelineColor.opacity(0.1) : nil
            )
        )
    }
}

private enum Occurrence {
    case event(Event)
    case crash(Crash)
    case hang(Hang)
    case resource(ResourceException)

    var date: Date {
        switch self {
        case .event(let event):
            event.date ?? .distantPast
        case .crash(let crash):
            crash.date ?? .distantPast
        case .hang(let hang):
            hang.date ?? .distantPast
        case .resource(let resource):
            resource.date ?? .distantPast
        }
    }
}
