//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Configuration passed to ``setup(container:options:)``.
///
/// Defaults preserve the behavior of the parameter-less ``setup(container:)``
/// overload. Tune individual fields to opt out of features or adjust limits.
///
public struct SetupOptions: Sendable {
    public var crashReporting: CrashReporting
    public var metrics: Metrics
    public var logging: Logging
    public var sync: SyncOptions
    public var retention: RetentionPolicy

    public init(
        crashReporting: CrashReporting = .enabled,
        metrics: Metrics = .enabled,
        logging: Logging = .enabled,
        sync: SyncOptions = SyncOptions(),
        retention: RetentionPolicy = RetentionPolicy()
    ) {
        self.crashReporting = crashReporting
        self.metrics = metrics
        self.logging = logging
        self.sync = sync
        self.retention = retention
    }
}

extension SetupOptions {
    public enum CrashReporting: Sendable, Equatable {
        case enabled
        case disabled
    }

    public enum Metrics: Sendable, Equatable {
        case enabled
        case disabled
    }

    public enum Logging: Sendable, Equatable {
        case enabled
        case disabled
    }
}

/// CloudKit sync tuning.
///
public struct SyncOptions: Sendable {
    /// Minimum remaining background time required before a CloudKit operation runs.
    public var backgroundTimeThreshold: TimeInterval

    /// Per-request and per-resource timeout for CloudKit operations.
    public var requestTimeout: TimeInterval

    /// Maximum number of retries when CloudKit reports `serverRecordChanged`.
    public var maxConflictRetries: Int

    public init(
        backgroundTimeThreshold: TimeInterval = 15,
        requestTimeout: TimeInterval = 10,
        maxConflictRetries: Int = 3
    ) {
        self.backgroundTimeThreshold = backgroundTimeThreshold
        self.requestTimeout = requestTimeout
        self.maxConflictRetries = maxConflictRetries
    }
}

/// Retention policy for locally persisted records awaiting sync.
///
public struct RetentionPolicy: Sendable {
    /// How long synced records are kept locally before cleanup deletes them.
    public var syncedRecordLifetime: TimeInterval

    /// How many failed sync attempts a record may accumulate before cleanup retires it.
    public var maxSyncAttempts: Int

    public init(
        syncedRecordLifetime: TimeInterval = 7 * 24 * 60 * 60,
        maxSyncAttempts: Int = 10
    ) {
        self.syncedRecordLifetime = syncedRecordLifetime
        self.maxSyncAttempts = maxSyncAttempts
    }
}

/// Active configuration consulted by sync, retention and runner code paths.
///
/// Written once by ``setup(container:options:)`` before any sync work runs;
/// readers from background contexts therefore observe a stable value.
///
nonisolated(unsafe) var activeSetupOptions = SetupOptions()
