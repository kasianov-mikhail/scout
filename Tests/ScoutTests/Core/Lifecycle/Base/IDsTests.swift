//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

// Serialized: both tests mutate the process-wide `IDs.session`, so the
// round-trip check must not overlap the concurrent-access stress test.
@Suite("IDs", .serialized)
struct IDsTests {
    @Test("session getter/setter round-trip")
    func sessionRoundTrip() {
        let uuid = UUID()
        IDs.session = uuid
        #expect(IDs.session == uuid)
    }

    @Test("concurrent session reads and writes are safe")
    func concurrentAccess() async {
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<500 {
                group.addTask { _ = IDs.session }
                group.addTask { IDs.session = UUID() }
            }
        }
    }
}
