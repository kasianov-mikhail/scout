//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

actor RecordCache: CacheClearing {
    private let storage: RecordCacheStorage
    lazy var context = storage.open()

    init(storage: RecordCacheStorage) {
        self.storage = storage
    }

    var size: Int64 {
        guard let context else {
            return 0
        }

        do {
            let rows = try context.performAndWait {
                let total = NSExpressionDescription()
                total.name = "total"
                total.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "size")])
                total.expressionResultType = .integer64AttributeType

                let request = NSFetchRequest<NSDictionary>(entityName: "CachedRecord")
                request.resultType = .dictionaryResultType
                request.propertiesToFetch = [total]
                return try context.fetch(request)
            }
            return rows.first?["total"] as? Int64 ?? 0
        } catch {
            print("Failed to measure the record cache: \(error)")
            return 0
        }
    }

    func removeAll() {
        storage.destroy(context: context)
        context = storage.open()
    }
}
