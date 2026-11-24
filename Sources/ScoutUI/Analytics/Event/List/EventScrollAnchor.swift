//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreGraphics
import Scout

struct EventScrollAnchor: Equatable {
    private(set) var id: Event.ID?

    mutating func track(frames: [Event.ID: CGRect]) {
        id =
            frames
            .filter { $0.value.minY <= 0 && $0.value.maxY > 0 }
            .max { $0.value.minY < $1.value.minY }?
            .key
    }

    func restoreID(records: [Event]) -> Event.ID? {
        guard let id else { return nil }
        guard records.contains(where: { $0.id == id }) else {
            return nil
        }
        return id
    }

    mutating func reset() {
        id = nil
    }
}
