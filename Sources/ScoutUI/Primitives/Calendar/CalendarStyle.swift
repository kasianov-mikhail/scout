//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

enum CalendarStyle: Identifiable {
    case capsule
    case cell

    var id: Self { self }
}

extension CalendarStyle {
    var spacing: CGFloat {
        switch self {
        case .capsule: 8
        case .cell: 4
        }
    }

    var unselectedFill: AnyShapeStyle {
        switch self {
        case .capsule: AnyShapeStyle(Color(.systemGray6))
        case .cell: AnyShapeStyle(Color.accentColor.opacity(0.10))
        }
    }
}
