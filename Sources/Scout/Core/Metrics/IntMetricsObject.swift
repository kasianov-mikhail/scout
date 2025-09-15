// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(IntMetricsObject)
final class IntMetricsObject: MetricsObject, Syncable {
    static func parse(of batch: [IntMetricsObject]) -> [GridCell<Int>] {
        batch.grouped(by: \.hour).mapValues { items in
            items.reduce(0) { $0 + Int($1.value) }
        }
        .map(Cell.init)
    }
}
