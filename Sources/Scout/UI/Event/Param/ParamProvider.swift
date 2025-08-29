//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor
class ParamProvider: ObservableObject, DataProvider {
    let recordID: CKRecord.ID
    
    typealias DataType = [Item]

    @Published var items: [Item]?
    
    var data: [Item]? { items }

    init(recordID: CKRecord.ID) {
        self.recordID = recordID
    }

    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }
}

extension ParamProvider {
    struct Item: Identifiable, Comparable, Hashable, CustomStringConvertible {
        static func < (lhs: Item, rhs: Item) -> Bool {
            lhs.key < rhs.key
        }

        let id = UUID()
        let key: String
        let value: String

        fileprivate static func fromData(_ data: Data) throws -> [Item] {
            try JSONDecoder().decode([String: String].self, from: data).map(Item.init)
        }

        var description: String {
            "\(key): \(value)"
        }
    }
}

extension ParamProvider {
    func fetch(in database: DatabaseController) async {
        do {
            items = try await database
                .record(for: recordID)["params"]
                .map(Item.fromData)?
                .sorted()
        } catch {
            error.logError()
            items = nil
        }
    }
}
