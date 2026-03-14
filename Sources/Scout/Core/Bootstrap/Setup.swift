//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import Logging
import Metrics

/// Sets up the application's core services and infrastructure.
///
/// This function initializes the global CloudKit container, configures the logging and metrics systems,
/// crash handler, and prepares notification activity listeners. It should be called on the main actor
/// during application startup, and should only be invoked once.
///
/// - Parameter container: The `CKContainer` instance to be used for all CloudKit operations.
///
/// - Throws: An error if the notification listener setup fails.
///
/// - Important: This function must be called from the main actor context.
///
/// Example usage:
/// ```swift
/// try await setup(container: CKContainer.default())
/// ```
@MainActor
public func setup(container: CKContainer) async throws {
    installExceptionHandler()
    installSignalHandler()
    
    await CrashArchive.system.flush()

    try NotificationListener.appState.setup()
    SyncController.shared.container = container
    LoggingSystem.bootstrap(CKLogHandler.init)
    MetricsSystem.bootstrap(TelemetryFactory())
}
