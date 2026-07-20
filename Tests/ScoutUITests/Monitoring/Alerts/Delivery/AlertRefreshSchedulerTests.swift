//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(BackgroundTasks)
    import BackgroundTasks
    import Foundation
    import Testing

    @testable import ScoutUI

    @MainActor
    struct AlertRefreshSchedulerTests {
        @Test("Registering hooks the alert task identifier")
        func register() {
            let stub = TaskSchedulerStub()
            let scheduler = AlertRefreshScheduler(scheduler: stub) {}

            #expect(scheduler.register())
            #expect(stub.registered == [AlertRefreshScheduler.taskIdentifier])
        }

        @Test("Scheduling submits an app-refresh request no earlier than the interval")
        func schedule() throws {
            let stub = TaskSchedulerStub()
            let scheduler = AlertRefreshScheduler(scheduler: stub, interval: 1800) {}

            scheduler.schedule()

            let request = try #require(stub.submitted.first as? BGAppRefreshTaskRequest)

            #expect(request.identifier == AlertRefreshScheduler.taskIdentifier)
            #expect(try #require(request.earliestBeginDate).timeIntervalSinceNow > 1700)
        }
    }

    private final class TaskSchedulerStub: AlertTaskScheduler, @unchecked Sendable {
        private let lock = NSLock()
        private var registeredStorage: [String] = []
        private var submittedStorage: [BGTaskRequest] = []

        var registered: [String] {
            lock.lock()
            defer { lock.unlock() }
            return registeredStorage
        }

        var submitted: [BGTaskRequest] {
            lock.lock()
            defer { lock.unlock() }
            return submittedStorage
        }

        func register(
            forTaskWithIdentifier identifier: String, using queue: DispatchQueue?,
            launchHandler: @escaping @Sendable (BGTask) -> Void
        ) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            registeredStorage.append(identifier)
            return true
        }

        func submit(_ taskRequest: BGTaskRequest) throws {
            lock.lock()
            defer { lock.unlock() }
            submittedStorage.append(taskRequest)
        }
    }
#endif
