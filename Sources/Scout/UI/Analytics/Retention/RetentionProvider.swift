//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

class RetentionProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[RetentionCohort]>?

    func fetch(in database: DatabaseReader) async throws -> [RetentionCohort] {
        try await database.retention(in: Calendar.utc.defaultRange)
    }
}
