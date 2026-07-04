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

struct ActivityPoint: Decodable {
    let date: Int64
    let dau: Int
    let wau: Int
    let mau: Int
}

extension ActivityProvider {
    static func fixture() -> ActivityProvider {
        let provider = ActivityProvider()
        provider.result = .success(ActivityPoint.samples)
        return provider
    }
}

extension ActivityPoint {
    static var samples: [ActivityPoint] {
        let end = Date().startOfDay
        return (0..<365).compactMap { day in
            Calendar.utc.date(byAdding: .day, value: -day, to: end).map {
                ActivityPoint(
                    date: $0.millisecondsSince1970,
                    dau: .random(in: 50...200),
                    wau: .random(in: 300...600),
                    mau: .random(in: 800...1500)
                )
            }
        }
    }
}
