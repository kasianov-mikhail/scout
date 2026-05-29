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
    let active: Set<RailKind>
    let isCrash: Bool
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?

    func groupID(_ kind: RailKind) -> UUID? {
        switch kind {
        case .install: installID
        case .launch: launchID
        case .session: sessionID
        }
    }
}

/// Whether the rail of `kind` is continuous between two adjacent rows —
/// true only when both rows belong to the same (non-nil) install / launch /
/// session group, so the rail breaks at section boundaries.
///
func connected(_ a: TimelineItem?, _ b: TimelineItem?, on kind: RailKind) -> Bool {
    guard let a, let b, a.active.contains(kind), b.active.contains(kind) else {
        return false
    }
    guard let groupA = a.groupID(kind), let groupB = b.groupID(kind) else {
        return false
    }
    return groupA == groupB
}

/// Two rows are in the same section when they share a (non-nil) session.
///
func sameSection(_ a: TimelineItem, _ b: TimelineItem) -> Bool {
    guard let sessionA = a.sessionID, let sessionB = b.sessionID else {
        return false
    }
    return sessionA == sessionB
}
