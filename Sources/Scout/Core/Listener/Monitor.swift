//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// A marker protocol for types that can perform both incremental
/// and full monitoring passes against a Core Data store.
///
protocol Monitor: PartialMonitor {
    static func complete(in context: NSManagedObjectContext) throws
}

/// A marker protocol for types that support an incremental monitoring pass.
///
protocol PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws
}
