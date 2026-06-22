//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

class QueryProvider<T: Combining & RecordDecodable>: ObservableObject, Provider {
    @Published var result: ProviderResult<[T]>?

    private let queryBuilder: () -> RecordQuery

    init(query: @escaping @autoclosure () -> RecordQuery) {
        self.queryBuilder = query
    }

    init(query: @escaping () -> RecordQuery) {
        self.queryBuilder = query
    }

    func fetch(in database: DatabaseReader) async throws -> [T] {
        try await database
            .readAll(matching: queryBuilder(), fields: nil)
            .map { try T(record: $0) }
            .mergeDuplicates()
    }
}
