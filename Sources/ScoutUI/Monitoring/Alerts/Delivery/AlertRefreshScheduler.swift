//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(BackgroundTasks) && !os(macOS)
    import BackgroundTasks
    import Foundation

    protocol AlertTaskScheduler: Sendable {
        func register(
            forTaskWithIdentifier identifier: String, using queue: DispatchQueue?,
            launchHandler: @escaping @Sendable (BGTask) -> Void
        ) -> Bool
        func submit(_ taskRequest: BGTaskRequest) throws
    }

    // BGTaskScheduler and BGTask are thread-safe but not annotated Sendable in the SDK.
    extension BGTaskScheduler: @retroactive @unchecked Sendable {}
    extension BGTask: @retroactive @unchecked Sendable {}

    extension BGTaskScheduler: AlertTaskScheduler {}

    @MainActor
    final class AlertRefreshScheduler {
        static let taskIdentifier = "scout.alert.refresh"

        private let scheduler: AlertTaskScheduler
        private let interval: TimeInterval
        private let refresh: @Sendable () async -> Void

        init(
            scheduler: AlertTaskScheduler = BGTaskScheduler.shared, interval: TimeInterval = 1800,
            refresh: @escaping @Sendable () async -> Void
        ) {
            self.scheduler = scheduler
            self.interval = interval
            self.refresh = refresh
        }

        @discardableResult
        func register() -> Bool {
            scheduler.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { [refresh, weak self] task in
                let work = Task {
                    await refresh()
                    await self?.schedule()
                    task.setTaskCompleted(success: true)
                }
                task.expirationHandler = { work.cancel() }
            }
        }

        func schedule() {
            let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
            try? scheduler.submit(request)
        }
    }
#endif
