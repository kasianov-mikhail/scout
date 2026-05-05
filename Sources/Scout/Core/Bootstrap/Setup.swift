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

struct SetupError: LocalizedError {
    let errorDescription: String? = "Scout is already setup"
    let recoverySuggestion: String? = "Review the code to ensure setup is called only once"
}

@MainActor private var isSetup = false

/// Initializes Scout's global infrastructure with the default options.
///
/// - Parameter container: The CloudKit container for all operations.
/// - Throws: An error if initialization fails or if called more than once.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(container: CKContainer) async throws {
    try await setup(container: container, options: SetupOptions())
}

/// Initializes Scout's global infrastructure with custom options.
///
/// - Parameters:
///   - container: The CloudKit container for all operations.
///   - options: Feature gates and tuning values; defaults preserve the
///     behavior of ``setup(container:)``.
/// - Throws: An error if initialization fails or if called more than once.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(container: CKContainer, options: SetupOptions) async throws {
    guard !isSetup else {
        throw SetupError()
    }

    activeSetupOptions = options

    if case .enabled = options.crashReporting {
        installExceptionHandler()
        installSignalHandler()
        await CrashArchive.system.flush()
    }

    try await persistentContainer.performBackgroundTasks(
        SessionObject.completeStale,
        LaunchObject.completeStale,
    )

    let syncController = SyncController(container: container)
    let sync = syncController.synchronize

    ActionTable.appState.startListening(completion: sync)

    try await persistentContainer.performBackgroundTasks(
        DeviceObject.trigger,
        InstallObject.trigger,
        VersionObject.trigger,
        LaunchObject.trigger,
        SessionObject.trigger,
        UserActivityObject.trigger
    )

    if case .enabled = options.logging {
        LoggingSystem.bootstrap { label in
            CKLogHandler(sync: sync, label: label)
        }
    }
    if case .enabled = options.metrics {
        MetricsSystem.bootstrap(TelemetryFactory(sync: sync))
    }

    isSetup = true
}
