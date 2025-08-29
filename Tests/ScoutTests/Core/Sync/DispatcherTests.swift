//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct DispatcherTests {
    enum TestError: Error {
        case test
    }

    let dispatcher = SkipDispatcher()

    @Test("Doesn't execute concurrent blocks") func testNotExecuteConcurrentBlocks() async throws {
        await confirmation { confirmation in
            await dispatcher.execute {
                confirmation()
                await dispatcher.execute {
                    confirmation()
                }
            }
        }
    }

    @Test("Execute serial blocks") func testExecuteSerialBlocks() async throws {
        await confirmation(expectedCount: 2) { confirmation in
            await dispatcher.execute {
                confirmation()
            }
            await dispatcher.execute {
                confirmation()
            }
        }
    }

    @Test("Error doesn't prevent execution") func testErrorNotPreventExecution() async throws {
        await confirmation(expectedCount: 2) { confirmation in
            try? await dispatcher.execute {
                confirmation()
                throw TestError.test
            }
            await dispatcher.execute {
                confirmation()
            }
        }
    }
}
