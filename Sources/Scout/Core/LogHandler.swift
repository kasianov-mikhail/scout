//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Logging

/// A log handler that sends log messages to CloudKit.
public struct CKLogHandler: LogHandler {
    let label: String
    let container: CKContainer

    /// Initializes a new instance of `CKLogHandler`.
    ///
    /// - Parameters:
    ///   - label: A label to identify the source of the log messages.
    ///   - container: The CloudKit container where log messages will be stored.
    ///
    public init(label: String, container: CKContainer) {
        self.label = label
        self.container = container
    }

    /// Metadata associated with the log handler.
    public var metadata: Logger.Metadata = [:]

    /// The log level for the log handler.
    public var logLevel: Logger.Level = .info

    /// Accesses the metadata for a given key.
    ///
    /// - Parameter key: The key for the metadata.
    /// - Returns: The metadata value associated with the key.
    ///
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
}

extension CKLogHandler {

    /// Logs a message with the specified log level and metadata.
    ///
    /// - Parameters:
    ///   - level: The log level of the message.
    ///   - message: The log message.
    ///   - metadata: Additional metadata for the log message.
    ///   - source: The source of the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line number where the log message originated.
    ///
    public func log(
        level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String,
        file: String, function: String, line: UInt
    ) {
        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    try Scout.log(
                        message.description,
                        level: level,
                        metadata: metadata,
                        date: Date(),
                        context: context
                    )
                }
                try await sync(in: container)

            } catch {
                print(error.localizedDescription)
            }
        }
    }
}