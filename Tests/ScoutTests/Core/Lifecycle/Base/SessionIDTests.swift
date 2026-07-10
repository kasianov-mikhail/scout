//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("SessionID")
struct SessionIDTests {
    @Test("current getter/setter round-trip")
    func currentRoundTrip() {
        let session = SessionID()
        let uuid = UUID()
        session.current = uuid
        #expect(session.current == uuid)
        #expect(session.raw == uuid)
    }

    @Test("concurrent reads and writes are safe")
    func concurrentAccess() async {
        let session = SessionID()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<500 {
                group.addTask { _ = session.current }
                group.addTask { session.current = UUID() }
            }
        }
    }
}
