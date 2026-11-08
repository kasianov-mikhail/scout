//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct NetworkLedgerRow: Identifiable {
    let date: Date
    let requests: Int
    let successRate: Stability?
    let p99: TimeInterval?
    let isCurrent: Bool

    var id: Date { date }
}
