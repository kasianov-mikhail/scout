//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import UIKit

/// An actor responsible for listening to application activity notifications and managing session monitoring.
///
/// The `ActivityListener` actor observes specific application lifecycle notifications to trigger and complete
/// session monitoring actions. It ensures that the session monitor is properly notified when the application
/// becomes active or resigns active.
///
/// - Note: This actor is implemented as a singleton using the `shared` static property.
///
/// - Throws: `ActivityListener.Error.alreadySetup` if the listener is already set up.
///
/// - Example:
/// ```swift
/// do {
///     try await ActivityListener.shared.setup()
/// } catch {
///     print(error.localizedDescription)
/// }
/// ```
///
/// - SeeAlso: `SessionMonitor`
///
public actor ActivityListener {

    enum Error: LocalizedError {
        case alreadySetup

        public var errorDescription: String? {
            switch self {
            case .alreadySetup:
                return "ActivityListener is already setup"
            }
        }
    }

    /// A singleton instance of `ActivityListener`.
    /// Use this shared instance to access the activity listener throughout the application.
    ///
    public static let shared = ActivityListener()

    // MARK: - Setup

    private var isSetup = false

    /// Sets up the activity listener.
    ///
    /// This method initializes and configures the necessary components for the activity listener
    /// to start monitoring and handling events.
    ///
    /// - Throws: An error if the listener is already set up.
    ///
    public func setup() throws {
        guard !isSetup else {
            throw Error.alreadySetup
        }

        isSetup = true

        Task(operation: observeBecomeActive)
        Task(operation: observeResignActive)
    }
}

// MARK: - Notifications

/// Extension for `ActivityListener` to handle notification observations.
///
/// This extension contains methods to observe specific application lifecycle notifications
/// and perform corresponding actions. It uses asynchronous sequences to listen for notifications
/// and execute the provided actions when the notifications are received.
///
/// - Note: This extension is used internally by the `ActivityListener` actor to manage
/// session monitoring based on application activity.
///
/// - SeeAlso: `ActivityListener.setup()`
///
extension ActivityListener {

    func observeBecomeActive() async {
        await notifications(named: UIApplication.didBecomeActiveNotification) {
            try await SessionMonitor.trigger()
        }
    }

    func observeResignActive() async {
        await notifications(named: UIApplication.willResignActiveNotification) {
            try await SessionMonitor.complete()
        }
    }
}

// MARK: - Private

extension ActivityListener {

    private typealias NotificationAction = () async throws -> Void

    private func notifications(named name: Notification.Name, action: NotificationAction) async {
        let notifications = NotificationCenter.default.notifications(named: name).map { _ in () }

        for await _ in notifications {
            do {
                try await action()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
