//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

@Suite("SyncGroup")
struct SyncGroupTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()
    let group: SyncGroup<EventObject>

    init() {
        let batch : [EventObject] = [
            .stub(name: "A", in: context),
            .stub(name: "A", in: context),
        ]
        group = SyncGroup<EventObject>(
            matrix: Matrix(
                recordType: "DateIntMatrix",
                date: Date(),
                name: "group_name",
                cells: EventObject.parse(of: batch)
            ),
            representables: nil,
            batch: batch
        )
    }
}
