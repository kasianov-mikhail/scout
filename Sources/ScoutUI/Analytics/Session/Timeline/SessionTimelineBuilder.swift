//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension SessionTimeline {
    init(info: SessionInfo, events: [Event], screens: [Screen], crashes: [Crash], hangs: [Hang], resources: [ResourceException], now: Date) {
        guard let start = info.startDate else {
            self.init(info: info, rows: [])
            return
        }

        var rows: [SessionTimelineRow] = [
            SessionTimelineRow(
                id: "start",
                kind: .start,
                height: .rowStep,
                title: "Session started",
                subtitle: SessionTimeline.startSubtitle(info: info, start: start),
                time: TimeInterval(0).sessionOffset
            )
        ]

        let occurrences = SessionOccurrence.all(events: events, screens: screens, crashes: crashes, hangs: hangs, resources: resources)
        var previous: Date?

        for (index, occurrence) in occurrences.enumerated() {
            if let previous {
                let gap = occurrence.date.timeIntervalSince(previous)
                if gap >= sessionGapThreshold {
                    rows.append(
                        SessionTimelineRow(
                            id: "gap-\(index)",
                            kind: .gap,
                            height: .rowStep,
                            title: gap.sessionDuration,
                            subtitle: nil,
                            time: nil
                        )
                    )
                }
            }

            rows.append(occurrence.row(start: start, info: info, now: now))
            previous = occurrence.date
        }

        let end = SessionTimeline.endRow(info: info, occurrences: occurrences, start: start, now: now)
        if let last = occurrences.last?.date, let anchor = end.anchor {
            let gap = anchor.timeIntervalSince(last)
            if gap >= sessionGapThreshold {
                rows.append(
                    SessionTimelineRow(
                        id: "gap-end",
                        kind: .gap,
                        height: .rowStep,
                        title: gap.sessionDuration,
                        subtitle: nil,
                        time: nil
                    )
                )
            }
        }

        rows.append(end.row)
        self.init(info: info, rows: rows)
    }

    private static func startSubtitle(info: SessionInfo, start: Date) -> String? {
        guard let launchDate = info.launchDate else {
            return nil
        }
        let delay = start.timeIntervalSince(launchDate)
        guard delay > 0 else {
            return nil
        }
        return "app launched \(delay.sessionDuration) before"
    }

    private static func endRow(info: SessionInfo, occurrences: [SessionOccurrence], start: Date, now: Date) -> EndRow {
        if let crash = latestCrash(occurrences), !occurrences.contains(where: { $0.date > crash.date }) {
            return EndRow(
                row: SessionTimelineRow(
                    id: "end",
                    kind: .end(.crash),
                    height: .rowStep,
                    title: "App crashed",
                    subtitle: nil,
                    time: crash.date.timeIntervalSince(start).sessionOffset
                ),
                anchor: crash.date
            )
        }

        if info.isLive {
            return EndRow(
                row: SessionTimelineRow(
                    id: "end",
                    kind: .end(.live),
                    height: .rowStep,
                    title: "Live",
                    subtitle: "the device is still sending",
                    time: "now"
                ),
                anchor: now
            )
        }

        if let endDate = info.endDate, endDate >= start {
            return EndRow(
                row: SessionTimelineRow(
                    id: "end",
                    kind: .end(.background),
                    height: .rowStep,
                    title: "Went to background",
                    subtitle: nil,
                    time: endDate.timeIntervalSince(start).sessionOffset
                ),
                anchor: endDate
            )
        }

        let date = occurrences.last?.date
        return EndRow(
            row: SessionTimelineRow(
                id: "end",
                kind: .end(.unknown),
                height: .rowStep,
                title: "Session end not recorded",
                subtitle: nil,
                time: date.map { "≈" + $0.timeIntervalSince(start).sessionOffset }
            ),
            anchor: nil
        )
    }

    private static func latestCrash(_ occurrences: [SessionOccurrence]) -> SessionOccurrence? {
        occurrences.last { occurrence in
            if case .crash = occurrence {
                true
            } else {
                false
            }
        }
    }
}

private struct EndRow {
    let row: SessionTimelineRow
    let anchor: Date?
}

private let sessionGapThreshold: TimeInterval = 2 * 60
