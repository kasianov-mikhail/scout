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
        let newer = sorted[(anchorIndex + 1)...].compactMap(\.installID)

        return (Array(older), Array(newer))
    }
}
