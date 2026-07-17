//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutTestSupport

@MainActor
@Suite("MainThreadBacktrace")
struct MainThreadBacktraceTests {
    @Test("captures the blocked main thread's stack from another thread")
    func capturesBlockedMainThread() {
        final class Box: @unchecked Sendable {
            var frames: [String] = []
        }
        let box = Box()
        let finished = DispatchSemaphore(value: 0)

        Thread {
            Thread.sleep(forTimeInterval: 0.05)
            box.frames = MainThreadBacktrace.capture()
            finished.signal()
        }.start()

        // Stands in for a hang: the main thread is unresponsive for this
        // whole window, and the background thread captures it partway through.
        Thread.sleep(forTimeInterval: 0.5)

        finished.wait()

        #expect(!box.frames.isEmpty)
        #expect(box.frames.allSatisfy { !$0.isEmpty })
    }
}
