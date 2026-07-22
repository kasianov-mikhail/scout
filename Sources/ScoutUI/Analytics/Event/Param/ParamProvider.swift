//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class ParamProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[Item]>?

    private let recordID: String

    init(recordID: String) {
        self.recordID = recordID
    }

    func fetch(in database: DatabaseReader) async throws -> Output {
        try await database
            .lookup(recordName: recordID, fields: ["params"])["params"]
            .map(Item.fromData)?
            .sorted() ?? []
    }
}
