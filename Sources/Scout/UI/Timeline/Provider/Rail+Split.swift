//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Rail {
    func split(at anchor: Event?) -> (older: [UUID], newer: [UUID])? {
        guard let anchorInstallID = anchor?.installID else {
            return nil
        }

        let sorted = installs.map(\.install).sorted(byDate: \.date)

        guard let anchorIndex = sorted.firstIndex(where: { $0.installID == anchorInstallID }) else {
            return nil
        }

        let older = sorted[0...anchorIndex].reversed().compactMap(\.installID)

        // With an anchor date the lanes split the anchor install between them
        // (`start_date` bound in `Session.fetchChunk` keeps them disjoint);
        // without one the whole anchor install stays in the older lane.
        let newerStart = anchor?.date == nil ? anchorIndex + 1 : anchorIndex
        let newer = sorted[newerStart...].compactMap(\.installID)

        return (Array(older), Array(newer))
    }
}
