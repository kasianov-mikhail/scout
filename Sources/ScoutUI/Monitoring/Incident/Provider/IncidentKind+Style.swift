//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension IncidentKind {
    var title: String {
        switch self {
        case .crash:
            "Crashes"
        case .hang:
            "Hangs"
        }
    }

    var color: Color {
        switch self {
        case .crash:
            .red
        case .hang:
            .orange
        }
    }
}
