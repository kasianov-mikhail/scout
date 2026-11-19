//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct IncidentSummaryCard: Identifiable {
    let title: String
    let value: String
    let change: String?
    let bars: [Double]

    var id: String {
        title
    }
}
