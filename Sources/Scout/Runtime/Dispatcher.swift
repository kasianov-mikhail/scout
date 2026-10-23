//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if os(iOS)
    import UIKit
#else
    import Foundation
#endif

protocol Dispatcher: Sendable {
    func perform(_ work: @escaping Work) async throws
}

extension Dispatcher {
    typealias Work = @Sendable () async throws -> Void
}

extension Dispatcher {
    func performEnsuringBackground(_ work: @escaping Work) async throws {
        #if os(iOS)
            try await perform { @MainActor in
                try await UIApplication.shared.performBackgroundTask(work: work)
            }
        #else
            try await perform(work)
        #endif
    }
}

#if os(iOS)
    @MainActor
    protocol BackgroundTaskHost {
        func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (@MainActor @Sendable () -> Void)?) -> UIBackgroundTaskIdentifier
        func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
    }

    extension UIApplication: BackgroundTaskHost {}

    extension BackgroundTaskHost {
        func performBackgroundTask(work: @escaping Dispatcher.Work) async throws {
            let work = Task(operation: work)
            let task = BackgroundTask(host: self, work: work)

            defer { task.end() }

            try await work.value
        }
    }

    @MainActor
    private final class BackgroundTask {
        private let host: any BackgroundTaskHost
        private var identifier = UIBackgroundTaskIdentifier.invalid

        init(host: any BackgroundTaskHost, work: Task<Void, any Error>) {
            self.host = host
            self.identifier = host.beginBackgroundTask(withName: "scout.sync") { [self] in
                work.cancel()
                end()
            }
        }

        func end() {
            guard identifier != .invalid else {
                return
            }
            host.endBackgroundTask(identifier)
            identifier = .invalid
        }
    }
#endif
