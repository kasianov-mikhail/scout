//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct TimelineItem: Identifiable {
    let id: RecordID
    let name: String
    let date: Date
    let active: Set<LegendKind>
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?

    func groupID(_ kind: LegendKind) -> UUID? {
        switch kind {
        case .install: installID
        case .launch: launchID
        case .session: sessionID
        }
    }
}

extension TimelineItem: Hashable {
    static func == (lhs: TimelineItem, rhs: TimelineItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
