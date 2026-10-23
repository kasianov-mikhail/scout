//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if os(iOS)
    import Testing
    import UIKit

    @testable import Scout

    @MainActor
    @Suite("Dispatcher")
    struct DispatcherTests {
        @Test("Finished work ends the background task once")
        func testFinishedWorkEndsTask() async throws {
            let application = SpyApplication()

            try await application.performBackgroundTask {}

            #expect(application.endedTasks == [application.task])
        }

        @Test("Expiration cancels the work and ends the background task before the work unwinds")
        func testExpirationEndsTask() async throws {
            let application = SpyApplication()
            let started = AsyncStream.makeStream(of: Void.self)
            let release = AsyncStream.makeStream(of: Void.self)

            let run = Task {
                try await application.performBackgroundTask {
                    started.continuation.yield()
                    await Task { for await _ in release.stream { break } }.value
                    try Task.checkCancellation()
                }
            }

            for await _ in started.stream { break }
            application.expire()

            #expect(application.endedTasks == [application.task])

            release.continuation.yield()

            await #expect(throws: CancellationError.self) {
                try await run.value
            }
            #expect(application.endedTasks == [application.task])
        }
    }

    @MainActor
    private final class SpyApplication: BackgroundTaskHost {
        let task = UIBackgroundTaskIdentifier(rawValue: 42)
        private(set) var endedTasks: [UIBackgroundTaskIdentifier] = []
        private var expirationHandler: (@MainActor @Sendable () -> Void)?

        func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (@MainActor @Sendable () -> Void)?) -> UIBackgroundTaskIdentifier {
            expirationHandler = handler
            return task
        }

        func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
            endedTasks.append(identifier)
        }

        func expire() {
            expirationHandler?()
        }
    }
#endif
