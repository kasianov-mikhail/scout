//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

class ParamProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[Item]>?

    private let recordID: RecordID

    init(recordID: RecordID) {
        self.recordID = recordID
    }

    func fetch(in database: AppDatabase) async throws -> Output {
        try await database
            .lookup(id: recordID, fields: ["params"])["params"]
            .map(Item.fromData)?
            .sorted() ?? []
    }
}
