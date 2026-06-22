//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation


class ActivityProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[ActivityPoint]>?

    func fetch(in database: DatabaseReader) async throws -> [ActivityPoint] {
        try await database.activity(in: Calendar.utc.defaultRange)
    }
}

protocol ActivityReader: RecordReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint]
}

struct ActivityPoint: Decodable, Equatable {
    let date: Int64
    let dau: Int
    let wau: Int
    let mau: Int
}
