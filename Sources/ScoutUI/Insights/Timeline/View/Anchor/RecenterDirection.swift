//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

enum RecenterDirection {
    case up
    case down

    init?(frame: CGRect, viewport: CGRect) {
        if frame.maxY <= viewport.minY {
            self = .up
        } else if frame.minY >= viewport.maxY {
            self = .down
        } else {
            return nil
        }
    }

    var symbol: String {
        switch self {
        case .up:
            "chevron.up"
        case .down:
            "chevron.down"
        }
    }
}
