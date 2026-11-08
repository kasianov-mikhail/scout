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
}
