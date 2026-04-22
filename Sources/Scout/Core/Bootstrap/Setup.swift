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

/// Initializes Scout's global infrastructure.
///
/// - Parameter container: The CloudKit container for all operations.
/// - Throws: An error if initialization fails or if called more than once.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(container: CKContainer) async throws {
    guard !isSetup else {
        throw SetupError()
    }
    isSetup = true

    installExceptionHandler()
    installSignalHandler()

    await CrashArchive.system.flush()
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

    LoggingSystem.bootstrap { label in
        CKLogHandler(sync: sync, label: label)
    }
    MetricsSystem.bootstrap(TelemetryFactory(sync: sync))
}
