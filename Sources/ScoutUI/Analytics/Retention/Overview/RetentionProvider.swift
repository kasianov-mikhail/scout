//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class RetentionProvider: ObservableObject, AudienceProvider {
    @Published var result: ProviderResult<[RetentionCohort]>?

    init(_ result: ProviderResult<Output>? = nil) {
        self.result = result
    }

    func fetch(in database: AudienceReader) async throws -> [RetentionCohort] {
        try await database.retention(in: Date().trailingYear)
    }
}
