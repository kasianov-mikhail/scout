//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

class ActivityProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[ActivityPoint]>?

    func fetch(in database: DatabaseReader) async throws -> [ActivityPoint] {
        try await database.activity(in: Calendar.utc.defaultRange)
    }
}

extension ActivityPoint: Fixture {
    static var samples: [ActivityPoint] {
        let end = Date().startOfDay
        return (0..<365).compactMap { day in
            Calendar.utc.date(byAdding: .day, value: -day, to: end).map {
                ActivityPoint(
                    date: $0.millisecondsSince1970,
                    dau: 80 + day % 90 + (day / 7) % 20,
                    wau: 360 + day % 120 + (day / 5) % 80,
                    mau: 950 + day % 240 + (day / 11) % 160
                )
            }
        }
    }
}
