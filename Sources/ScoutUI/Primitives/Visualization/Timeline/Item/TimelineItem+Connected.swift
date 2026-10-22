//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension TimelineItem {
    func isConnected(other: TimelineItem?, kind: LegendKind) -> Bool {
        guard let other, active.contains(kind), other.active.contains(kind) else {
            return false
        }
        guard let group = groupID(kind), let otherGroup = other.groupID(kind) else {
            return false
        }
        return group == otherGroup
    }
}
