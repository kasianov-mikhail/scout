//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import MachO
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("MainThreadBacktrace")
struct MainThreadBacktraceTests {
    @Test("captures the blocked main thread's stack from another thread")
    func capturesBlockedMainThread() throws {
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

        let backtrace = Backtrace(addresses: box.addresses, images: LoadedImage.loaded())
        let frames = backtrace.threads[0].frames
        let bottom = try #require(frames.last?.image)

        #expect(backtrace.images[bottom].name == "dyld")
        #expect(zip(box.addresses, frames).allSatisfy { $1.image != nil || isInLinker(address: $0) })
    }

    @Test("leaves the main thread's send rights unchanged")
    func keepsSendRights() {
        let port = mach_thread_self()
        defer { mach_port_deallocate(mach_task_self_, port) }
        let before = sendRights(port: port)
        let finished = DispatchSemaphore(value: 0)

        Thread {
            for _ in 0..<10 {
                _ = MainThreadBacktrace.capture()
            }
            finished.signal()
        }.start()

        finished.wait()

        #expect(sendRights(port: port) == before)
    }
}

private func isInLinker(address: UInt64) -> Bool {
    var info = Dl_info()
    guard dladdr(UnsafeRawPointer(bitPattern: UInt(address)), &info) != 0, let base = info.dli_fbase else {
        return false
    }
    return base.assumingMemoryBound(to: mach_header.self).pointee.filetype == UInt32(MH_DYLINKER)
}

private func sendRights(port: mach_port_t) -> mach_port_urefs_t {
    var refs: mach_port_urefs_t = 0
    mach_port_get_refs(mach_task_self_, port, MACH_PORT_RIGHT_SEND, &refs)
    return refs
}
