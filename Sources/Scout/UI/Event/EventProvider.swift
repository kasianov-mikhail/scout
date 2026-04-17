//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import SwiftUI

@MainActor
class EventProvider: PaginatingProvider<Event> {
    func fetch(for filter: Event.Query, in database: AppDatabase) async {
        let query = CKQuery(recordType: EventObject.recordType, predicate: filter.buildPredicate())
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        await fetch(matching: query, fields: Event.desiredKeys, in: database)
    }
}
