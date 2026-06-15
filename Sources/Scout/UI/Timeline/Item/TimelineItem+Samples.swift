//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension TimelineItem {
    static let samples: [TimelineItem] = {
        let start = Date().addingTimeInterval(-300)
        let installID = UUID()
        let launchID = UUID()
        let sessionID = UUID()

        func item(_ name: String, offset: TimeInterval) -> TimelineItem {
            TimelineItem(
                id: RecordID(recordName: UUID().uuidString),
                name: name,
                date: start.addingTimeInterval(offset),
                active: [.install, .launch, .session],
                installID: installID,
                launchID: launchID,
                sessionID: sessionID
            )
        }

        return [
            item("setup", offset: 20),
            item("ip_lookup", offset: 80),
            item("search", offset: 160),
        ]
    }()
}
