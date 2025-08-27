// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension DoubleMetricsObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Cell<Double>>? {
        try metricsGroup(in: context, valuePath: \.doubleValue)
    }
}

extension IntMetricsObject: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Int>? {
        try metricsGroup(in: context, valuePath: \.intValueCast)
    }
}

extension IntMetricsObject {
    fileprivate var intValueCast: Int {
        Int(intValue)
    }
}
