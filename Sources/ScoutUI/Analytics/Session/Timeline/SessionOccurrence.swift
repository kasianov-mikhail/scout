//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum SessionOccurrence {
    case event(Event, Date)
    case screen(Screen, Date)
    case crash(Crash, Date)
    case hang(Hang, Date)
    case resource(ResourceException, Date)

    static func all(events: [Event], screens: [Screen], crashes: [Crash], hangs: [Hang], resources: [ResourceException]) -> [SessionOccurrence] {
        var result: [SessionOccurrence] = []

        result += events.compactMap { event -> SessionOccurrence? in event.date.map { .event(event, $0) } }
        result += screens.compactMap { screen -> SessionOccurrence? in screen.startDate.map { .screen(screen, $0) } }
        result += crashes.compactMap { crash -> SessionOccurrence? in crash.date.map { .crash(crash, $0) } }
        result += hangs.compactMap { hang -> SessionOccurrence? in hang.date.map { .hang(hang, $0) } }
        result += resources.compactMap { resource -> SessionOccurrence? in resource.date.map { .resource(resource, $0) } }

        return result.sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }
    }

    var date: Date {
        switch self {
        case .event(_, let date), .screen(_, let date), .crash(_, let date), .hang(_, let date), .resource(_, let date):
            date
        }
    }

    var id: String {
        switch self {
        case .event(let event, _):
            event.id
        case .screen(let screen, _):
            screen.id
        case .crash(let crash, _):
            crash.id
        case .hang(let hang, _):
            hang.id
        case .resource(let resource, _):
            resource.id
        }
    }

    func row(start: Date, info: SessionInfo, now: Date) -> SessionTimelineRow {
        switch self {
        case .event(let event, let date):
            SessionTimelineRow(
                id: event.id,
                kind: .event(event),
                height: .rowRegular,
                title: event.name,
                subtitle: nil,
                time: date.timeIntervalSince(start).sessionOffset
            )
        case .screen(let screen, let date):
            SessionTimelineRow(
                id: screen.id,
                kind: .screen(screen),
                height: .rowRegular,
                title: screen.name,
                subtitle: screen.duration(now: now, live: info.isLive),
                time: date.timeIntervalSince(start).sessionOffset
            )
        case .crash(let crash, let date):
            SessionTimelineRow(
                id: crash.id,
                kind: .crash(crash),
                height: .rowRegular,
                title: "Crash",
                subtitle: crash.name,
                time: date.timeIntervalSince(start).sessionOffset
            )
        case .hang(let hang, let date):
            SessionTimelineRow(
                id: hang.id,
                kind: .hang(hang),
                height: .rowRegular,
                title: "Hang",
                subtitle: hang.duration.duration,
                time: date.timeIntervalSince(start).sessionOffset
            )
        case .resource(let resource, _):
            SessionTimelineRow(
                id: resource.id,
                kind: .resource(resource),
                height: .rowRegular,
                title: resource.name,
                subtitle: resource.reason,
                time: "~"
            )
        }
    }
}

extension Screen {
    fileprivate func duration(now: Date, live: Bool) -> String? {
        guard let startDate else {
            return nil
        }
        if let endDate, endDate >= startDate {
            return endDate.timeIntervalSince(startDate).sessionDuration
        }
        guard live else {
            return nil
        }
        return now.timeIntervalSince(startDate).sessionDuration + " so far"
    }
}
