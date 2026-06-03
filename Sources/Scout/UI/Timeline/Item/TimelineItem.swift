//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct TimelineItem: Identifiable {
    let id: CKRecord.ID
    let name: String
    let date: Date
    let active: Set<LegendKind>
    let isCrash: Bool
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
