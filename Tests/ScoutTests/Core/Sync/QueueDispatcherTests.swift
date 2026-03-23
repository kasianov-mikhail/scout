//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("QueueDispatcher")
struct QueueDispatcherTests {
    @Test("Single work item executes to completion")
    func testSingleWorkExecutes() async throws {
        let dispatcher = QueueDispatcher()
        let box = Box(0)

        try await dispatcher.perform {
            box.value = 42
        }

        #expect(box.value == 42)
    }

    @Test("Error from work is propagated to the caller")
    func testErrorPropagates() async {
        let dispatcher = QueueDispatcher()

        await #expect(throws: MonitorError.notFound) {
            try await dispatcher.perform {
                throw MonitorError.notFound
            }
        }
    }

    @Test("After an error, new work can still be performed")
    func testRecoveryAfterError() async throws {
        let dispatcher = QueueDispatcher()
        let box = Box(false)

        _ = try? await dispatcher.perform {
            throw MonitorError.notFound
        }

        try await dispatcher.perform {
            box.value = true
        }

        #expect(box.value)
    }

    @Test("Multiple sequential calls each execute their work")
    func testMultipleSequentialCalls() async throws {
        let dispatcher = QueueDispatcher()
        let box = Box(0)

        for _ in 1...3 {
            try await dispatcher.perform {
                box.value += 1
            }
        }

        #expect(box.value == 3)
    }
}

private final class Box<T>: @unchecked Sendable {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
