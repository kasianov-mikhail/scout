//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import UIKit

/// `NotificationListener` is a class that listens for notifications and performs actions in response.
///
/// - Note: This class is designed to be used as a singleton with a shared instance `activity`.
///
public class NotificationListener {

    /// An asynchronous action that can be performed in response to a notification.
    typealias Action = @Sendable () async throws -> Void

    /// A table mapping notification names to actions.
    typealias ActionTable = [Notification.Name: Action]

    private let table: ActionTable

    /// Initializes a new `NotificationListener` with the provided action table.
    ///
    /// - Parameter table: A dictionary mapping notification names to actions.
    ///
    init(table: ActionTable) {
        self.table = table
    }

    // MARK: - Activity Listener

    /// Shared instance of `NotificationListener` for handling application activity notifications.
    ///
    @MainActor public static let activity = NotificationListener(table: [
        UIApplication.willEnterForegroundNotification: {
            try await persistentContainer.performBackgroundTask(Session.trigger)
            try await persistentContainer.performBackgroundTask(UserActivity.trigger)
            try await sync(in: container)
        },
        UIApplication.didEnterBackgroundNotification: {
            try await persistentContainer.performBackgroundTask(Session.complete)
            try await persistentContainer.performBackgroundTask(UserActivity.trigger)
            try await sync(in: container)
        },
    ])

    // MARK: - Error

    enum Error: LocalizedError {
        case alreadySetup

        var errorDescription: String? {
            switch self {
            case .alreadySetup:
                return "NotificationListener is already setup"
            }
        }
    }

    // MARK: - Setup

    private var isSetup = false

    /// Sets up the notification listener by adding observers for the notifications in the action table.
    ///
    /// - Throws: `NotificationListener.Error.alreadySetup` if the listener has already been set up.
    ///
    public func setup() throws {
        guard !isSetup else {
            throw Error.alreadySetup
        }

        isSetup = true
        table.observe()
    }
}

// MARK: - Observe

extension NotificationListener.ActionTable {

    /// Observes the notifications in the action table and performs the associated actions.
    fileprivate func observe() {
        for (name, action) in self {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                Task(operation: action)
            }
        }
    }
}
