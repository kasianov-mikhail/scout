//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class ParamProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[Item]>?

    private let recordID: CKRecord.ID

    init(recordID: CKRecord.ID) {
        self.recordID = recordID
    }

    func fetch(in database: DatabaseController) async throws -> ResultType {
        try await database
            .record(for: recordID)["params"]
            .map(Item.fromData)?
            .sorted() ?? []
    }
}
