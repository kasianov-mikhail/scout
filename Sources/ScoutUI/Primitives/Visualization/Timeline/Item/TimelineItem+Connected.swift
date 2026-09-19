//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension TimelineItem {
    /// Whether the rail of `kind` is continuous between this row and `other`.
    ///
    /// True only when both rows belong to the same (non-nil) install / launch /
    /// session group, so the rail breaks at section boundaries.
    ///
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
