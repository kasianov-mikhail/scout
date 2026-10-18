//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("MainThreadBacktrace")
struct MainThreadBacktraceTests {
    @Test("captures the blocked main thread's stack from another thread")
    func capturesBlockedMainThread() {
        final class Box: @unchecked Sendable {
            var addresses: [UInt64] = []
        }
        let box = Box()
        let finished = DispatchSemaphore(value: 0)

        Thread {
            Thread.sleep(forTimeInterval: 0.05)
            box.addresses = MainThreadBacktrace.capture()
            finished.signal()
        }.start()

        // Stands in for a hang: the main thread is unresponsive for this
        // whole window, and the background thread captures it partway through.
        Thread.sleep(forTimeInterval: 0.5)

        finished.wait()

        let frames = Backtrace(addresses: box.addresses, images: LoadedImage.loaded()).threads[0].frames

        #expect(!frames.isEmpty)
        #expect(frames.allSatisfy { $0.image != nil })
    }
}
