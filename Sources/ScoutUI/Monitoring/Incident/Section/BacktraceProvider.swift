//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

@MainActor
final class BacktraceProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<Backtrace?>?

    private let incidentID: String

    init(_ result: ProviderResult<Output>? = nil, incidentID: String) {
        self.incidentID = incidentID
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> Backtrace? {
        guard let id = UUID(uuidString: incidentID) else {
            return nil
        }
        do {
            let record = try await database.lookup(
                recordName: UUID(incidentBacktrace: id).uuidString,
                fields: ["backtrace"]
            )

            guard let data: Data = record["backtrace"] else {
                return nil
            }
            return try JSONDecoder().decode(Backtrace.self, from: data)
        } catch is RecordNotFoundError {
            return nil
        }
    }
}
