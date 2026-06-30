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

    func startListening(completion: @escaping Action) {
        for (name, action) in actions {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                Task {
                    try await action()
                    try await completion()
                }
            }
        }
    }
}

extension ActionTable {
    static let appState = ActionTable(actions: [
        AppLifecycle.willEnterForeground: {
            try await persistentContainer.performBackgroundTasks(
                SessionObject.trigger,
                UserActivityObject.trigger,
                VersionMarker.trigger
            )
        },
        AppLifecycle.didEnterBackground: {
            try await persistentContainer.performBackgroundTasks(
                SessionObject.complete,
                UserActivityObject.trigger
            )
        },
    ])
}

enum AppLifecycle {
    static var willEnterForeground: Notification.Name {
        #if canImport(UIKit)
            UIApplication.willEnterForegroundNotification
        #else
            NSApplication.willBecomeActiveNotification
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
