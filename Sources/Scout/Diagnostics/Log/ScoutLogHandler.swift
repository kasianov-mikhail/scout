//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Logging

/// A `swift-log` handler that records every log event and syncs it to the given backends.
///
/// Bootstrap it on its own, or multiplex it with handlers of your own — Scout claims no
/// exclusive hold on the logging system:
///
/// ```swift
/// LoggingSystem.bootstrap { label in
///     MultiplexLogHandler([
///         ScoutLogHandler(label: label, runtime: scout),
///         StreamLogHandler.standardOutput(label: label),
///     ])
/// }
/// ```
///
/// Every handler shares the ``Runtime`` it is given, so build the runtime once and pass
/// the same one here and to ``ScoutMetricsFactory``.
///
public struct ScoutLogHandler: LogHandler {
    let runtime: Runtime

    /// The label of the logger this handler belongs to.
    public let label: String

    public var metadata: Logger.Metadata = [:]

    public var logLevel: Logger.Level = .info

    /// Creates a handler that records into the given runtime.
    ///
    /// - Parameters:
    ///   - label: The label of the logger this handler belongs to.
    ///   - runtime: The runtime to record into, shared with every other Scout handler.
    ///
    public init(label: String, runtime: Runtime) {
        self.runtime = runtime
        self.label = label
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    public func log(event: LogEvent) {
        guard runtime.isEnabled else {
            return
        }

        let date = Date()
        let identity = runtime.identity.snapshot

        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    try Scout.log(event, date: date, identity: identity, context: context)
                }
                try await runtime.sync()
            } catch {
                print("Failed to save log: \(error)")
            }
        }
    }
}
