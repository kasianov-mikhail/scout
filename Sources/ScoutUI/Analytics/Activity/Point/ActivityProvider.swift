//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class ActivityProvider: ObservableObject, AudienceProvider {
    @Published var result: ProviderResult<[ActivityPoint]>?

    init(_ result: ProviderResult<Output>? = nil) {
        self.result = result
    }

    func fetch(in database: AudienceReader) async throws -> [ActivityPoint] {
        try await database.activity(in: Date().trailingYear)
    }
}
