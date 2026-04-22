//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class QueryProvider<T: Combining & CKInitializable>: ObservableObject, Provider {
    @Published var result: ProviderResult<[T]>?

    private let queryBuilder: () -> CKQuery

    init(query: @escaping @autoclosure () -> CKQuery) {
        self.queryBuilder = query
    }

    init(query: @escaping () -> CKQuery) {
        self.queryBuilder = query
    }

    func fetch(in database: AppDatabase) async throws -> [T] {
        try await database
            .readAll(matching: queryBuilder(), fields: nil)
            .map { try T(record: $0) }
            .mergeDuplicates()
    }
}
