//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A display option for comparing the visible time window with the one before it.
enum ChartComparison: String, CaseIterable, Identifiable {
    case overlay
    case split

    var id: Self { self }
}

extension ChartComparison {
    var title: String {
        switch self {
        case .overlay:
            "Overlay"
        case .split:
            "Split"
        }
    }
}
