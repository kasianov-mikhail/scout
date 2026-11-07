//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Rail {
    func split(anchor: TimelineAnchor?) -> (older: [UUID], newer: [UUID])? {
        guard let anchor else {
            return nil
        }

        let sorted = installs.map(\.install)
        let anchorIndex: Int?

        if let installID = anchor.installID {
            anchorIndex = sorted.firstIndex { $0.installID == installID }
        } else if let date = anchor.date {
            anchorIndex = sorted.lastIndex { ($0.date ?? .distantPast) <= date }
        } else {
            anchorIndex = nil
        }

        guard let anchorIndex else {
            return nil
        }

        let older = sorted[0...anchorIndex].reversed().compactMap(\.installID)

        let newerStart = anchor.date == nil ? anchorIndex + 1 : anchorIndex
        let newer = sorted[newerStart...].compactMap(\.installID)

        return (Array(older), Array(newer))
    }

    func split(at anchor: Event?) -> (older: [UUID], newer: [UUID])? {
        guard let anchor, anchor.installID != nil else {
            return nil
        }
        return split(anchor: TimelineAnchor(date: anchor.date, installID: anchor.installID))
    }
}
