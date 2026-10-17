//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class CrashThreadsProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<[CrashThread]>?

    private let crashID: String

    init(_ result: ProviderResult<Output>? = nil, crashID: String) {
        self.crashID = crashID
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> [CrashThread] {
        let record = try await database.lookup(recordName: crashID, fields: ["threads"])
        guard let data: Data = record["threads"] else {
            return []
        }
        return try JSONDecoder().decode([CrashThread].self, from: data)
    }
}
