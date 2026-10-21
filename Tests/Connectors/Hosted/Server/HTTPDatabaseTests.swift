//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import HostedConnector

@Suite("Hosted HTTP requests")
struct HTTPDatabaseTests {
    @Test("A cancelled request throws CancellationError")
    func cancellation() async {
        let database = HTTPDatabase(url: URL(string: "https://unreachable.scout.test/")!, apiKey: nil)
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await database.perform(URLRequest(url: database.url))
        }

        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }
}
