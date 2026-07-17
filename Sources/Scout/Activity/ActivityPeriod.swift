//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package enum ActivityPeriod: Identifiable, CaseIterable, Equatable {
    case daily
    case weekly
    case monthly

    package var id: Self { self }

    var title: String {
        switch self {
        case .daily:
            "Daily"
        case .weekly:
            "Weekly"
        case .monthly:
            "Monthly"
        }
    }
}
