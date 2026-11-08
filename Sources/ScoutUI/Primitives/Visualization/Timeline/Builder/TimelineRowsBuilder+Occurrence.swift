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
    mutating func appendOccurrence(_ occurrence: Occurrence, isLast: Bool) {
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

enum Occurrence {
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
