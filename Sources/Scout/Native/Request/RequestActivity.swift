//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Combine
import ScoutDB

/// The in-flight CloudKit requests the toolbar gauge draws.
///
/// ScoutDB throttles every request and reports its slots to `cloudKitRequestActivity`;
/// this mirrors that count onto the main actor so SwiftUI can observe it.
///
@MainActor final class RequestActivity: ObservableObject {
    static let shared = RequestActivity(limit: cloudKitParallelismLimit)

    let limit: Int

    @Published private(set) var running = 0

    init(limit: Int) {
        self.limit = limit
    }

    var fraction: Double {
        limit > 0 ? min(Double(running) / Double(limit), 1) : 0
    }

    var isSaturated: Bool {
        running >= limit
    }

    func track(_ updates: AsyncStream<Int>) async {
        for await count in updates {
            running = count
        }
    }
}
