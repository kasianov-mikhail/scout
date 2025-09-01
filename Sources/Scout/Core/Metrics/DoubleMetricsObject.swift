//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@objc(DoubleMetricsObject)
final class DoubleMetricsObject: MetricsObject, Syncable {
    static func parse(of batch: [DoubleMetricsObject]) -> [Cell<Double>] {
        batch.grouped(by: \.hour).mapValues { items in
            items.reduce(0) { $0 + $1.doubleValue }
        }
        .map(Cell.init)
    }
}
