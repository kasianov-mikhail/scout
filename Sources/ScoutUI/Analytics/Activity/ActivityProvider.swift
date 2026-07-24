//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class ActivityProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[ActivityPoint]>?

    func fetch(in database: DatabaseReader) async throws -> [ActivityPoint] {
        try await database.activity(in: Calendar.utc.defaultRange)
    }
}
