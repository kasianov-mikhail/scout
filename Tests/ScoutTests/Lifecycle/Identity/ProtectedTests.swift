//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("Protected")
struct ProtectedTests {
    @Test("current getter/setter round-trip")
    func currentRoundTrip() {
        let box = Protected(UUID())
        let uuid = UUID()
        box.current = uuid
        #expect(box.current == uuid)
        #expect(box.raw == uuid)
    }

    @Test("concurrent reads and writes are safe")
    func concurrentAccess() async {
        let box = Protected(UUID())
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<500 {
                group.addTask { _ = box.current }
                group.addTask { box.current = UUID() }
            }
        }
    }
}
