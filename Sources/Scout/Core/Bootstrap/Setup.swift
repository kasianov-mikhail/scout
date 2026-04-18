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

/// Initializes Scout's global infrastructure.
///
/// - Parameter container: The CloudKit container for all operations.
/// - Throws: An error if initialization fails.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(container: CKContainer) async throws {
    installExceptionHandler()
    installSignalHandler()

    await CrashArchive.system.flush()
    try await persistentContainer.performBackgroundTask(completeStaleSessions)

    let syncController = SyncController(container: container)
    let sync = syncController.synchronize

    try NotificationListener.appState(sync: sync).setup()

    try await persistentContainer.performBackgroundTasks(
        DeviceObject.trigger,
        InstallObject.trigger,
        VersionObject.trigger,
        LaunchObject.trigger
    )

    LoggingSystem.bootstrap { label in
        CKLogHandler(sync: sync, label: label)
    }
    MetricsSystem.bootstrap(TelemetryFactory(sync: sync))
}
