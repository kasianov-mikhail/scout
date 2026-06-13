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

struct NoBackendsError: LocalizedError {
    let errorDescription: String? = "Scout requires at least one backend"
    let recoverySuggestion: String? = "Pass a CloudKit container or a Scout server to setup"
}

@MainActor private var isSetup = false

/// Initializes Scout's global infrastructure against a CloudKit container.
///
/// - Parameter container: The CloudKit container for all operations.
/// - Throws: An error if initialization fails or if called more than once.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(container: CKContainer) async throws {
    try await setup(backends: [.cloudKit(container)])
}

/// Initializes Scout's global infrastructure against one or more backends.
///
/// Every raw record is synced to every backend. CloudKit backends also
/// receive client-maintained matrix records; Scout servers aggregate
/// natively and receive raw metric values instead.
///
/// - Parameter backends: The backends to sync to, in any combination of
///   CloudKit containers and Scout servers.
/// - Throws: An error if initialization fails or if called more than once.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(backends: [Backend]) async throws {
    guard !isSetup else {
        throw SetupError()
    }
    guard !backends.isEmpty else {
        throw NoBackendsError()
    }

    warnAboutCleartextKeys(in: backends)

    installExceptionHandler()
    installSignalHandler()

    await CrashArchive.system.flush()
    try await persistentContainer.performBackgroundTasks(
        SessionObject.completeStale,
        LaunchObject.completeStale,
    )

    let sync = SyncController(backends: backends.map(\.resolved)).synchronize

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

    isSetup = true

    for case .cloudKit(let container) in backends {
        verifyParallelismIfDue(container: container)
    }
}

/// Warns when an API key would be sent to a Scout server over a connection
/// that isn't HTTPS, where the key — and every uploaded analytics record —
/// would travel in cleartext and be readable by any network observer.
///
private func warnAboutCleartextKeys(in backends: [Backend]) {
    for case .server(let url, _?) in backends where url.scheme?.lowercased() != "https" {
        print("[Scout] The API key for '\(url)' will be sent over a non-HTTPS connection in cleartext. Use an https:// URL.")
    }
}
