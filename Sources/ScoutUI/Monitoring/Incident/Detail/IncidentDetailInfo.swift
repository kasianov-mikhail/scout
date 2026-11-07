//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

protocol IncidentDetailInfo {
    var detailMeta: IncidentDetailMeta { get }
    var detailCulprit: String { get }
    var detailThread: String { get }
    var detailGroupTitle: String { get }
    var detailCount: String { get }
    var detailFocus: TimelineFocus { get }
}

struct IncidentDetailMeta {
    var date: Date?
    var interval: DateInterval?
    var accent: String?
    var source: String?

    var dateText: String? {
        if let interval {
            let day = detailDayFormatter.string(from: interval.start)
            let start = detailMinuteFormatter.string(from: interval.start)
            let end = detailMinuteFormatter.string(from: interval.end)
            if Calendar.utc.isDate(interval.start, inSameDayAs: interval.end) {
                return "\(day) · \(start)–\(end)"
            }
            return "\(day) \(start) – \(detailDayFormatter.string(from: interval.end)) \(end)"
        }
        guard let date else {
            return nil
        }
        return "\(detailDayFormatter.string(from: date)) · \(detailTimeFormatter.string(from: date))"
    }
}

private let detailDayFormatter = DateFormatter(format: "EEE, MMM d")
private let detailTimeFormatter = DateFormatter(format: "HH:mm:ss")
private let detailMinuteFormatter = DateFormatter(format: "HH:mm")

extension Crash: IncidentDetailInfo {
    var detailMeta: IncidentDetailMeta {
        switch source {
        case .metricKit(let windowStart):
            if let windowStart, let date, windowStart <= date {
                return IncidentDetailMeta(interval: DateInterval(start: windowStart, end: date), source: "MetricKit report")
            }
            return IncidentDetailMeta(date: date, source: "MetricKit report")
        case .inProcess:
            return IncidentDetailMeta(date: date, source: "in-process report")
        }
    }

    var detailCulprit: String {
        "Crashed in"
    }

    var detailThread: String {
        "crashed thread"
    }

    var detailGroupTitle: String {
        "Same crash"
    }

    var detailCount: String {
        "time"
    }

    var detailFocus: TimelineFocus {
        TimelineFocus(crash: self)
    }
}

extension Hang: IncidentDetailInfo {
    var detailMeta: IncidentDetailMeta {
        IncidentDetailMeta(date: date, accent: "\(severity.detailLabel), \(duration.duration)")
    }

    var detailCulprit: String {
        "Blocked in"
    }

    var detailThread: String {
        "main thread"
    }

    var detailGroupTitle: String {
        "Same hang"
    }

    var detailCount: String {
        "time"
    }

    var detailFocus: TimelineFocus {
        TimelineFocus(hang: self)
    }
}

extension ResourceException: IncidentDetailInfo {
    var detailMeta: IncidentDetailMeta {
        IncidentDetailMeta(date: date, source: "MetricKit report")
    }

    var detailCulprit: String {
        switch resourceKind {
        case .cpu?:
            "Most CPU time in"
        case .diskWrite?:
            "Most disk writes in"
        case nil:
            "Most time in"
        }
    }

    var detailThread: String {
        "heaviest thread"
    }

    var detailGroupTitle: String {
        "Same exception"
    }

    var detailCount: String {
        "report"
    }

    var detailFocus: TimelineFocus {
        TimelineFocus(resource: self)
    }
}
