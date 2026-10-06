//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class ParamProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<[Item]>?

    private let recordID: String

    init(_ result: ProviderResult<Output>? = nil, recordID: String) {
        self.recordID = recordID
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> Output {
        try await database
            .lookup(recordName: recordID, fields: ["params"])["params"]
            .map(Item.fromData)?
            .sorted() ?? []
    }
}
