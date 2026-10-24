//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

struct ActionTable {
    typealias Action = @Sendable () async throws -> Void

    let actions: [Notification.Name: Action]
    private let tail = Protected(Task<Void, Never> {})

    func startListening(completion: @escaping Action) {
        for (name, action) in actions {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                let task = perform(action: action)
                Task {
                    await task.value
                    await run(completion)
                }
            }
        }
    }

    func perform(action: @escaping Action) -> Task<Void, Never> {
        tail.mutate { tail in
            let previous = tail
            tail = Task {
                await previous.value
                await run(action)
            }
        }
    }
}

private func run(_ action: ActionTable.Action) async {
    do {
        try await action()
    } catch {
        print("Failed to run action: \(error)")
    }
}

package enum AppLifecycle {
    package static var willEnterForeground: Notification.Name {
        #if canImport(UIKit)
            UIApplication.willEnterForegroundNotification
        #else
            NSApplication.willBecomeActiveNotification
        #endif
    }

    @MainActor
    static var isInForeground: Bool {
        #if canImport(UIKit)
            UIApplication.shared.applicationState != .background
        #else
            true
        #endif
    }

    static var didEnterBackground: Notification.Name {
        #if canImport(UIKit)
            UIApplication.didEnterBackgroundNotification
        #else
            NSApplication.didResignActiveNotification
        #endif
    }
}
