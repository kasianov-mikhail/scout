//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Logging

/// A log handler that persists log events to CloudKit via Core Data.
///
struct CKLogHandler: LogHandler {
    let sync: SyncAction
    let label: String

    var metadata: Logger.Metadata = [:]

    var logLevel: Logger.Level = .info

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let sync = self.sync
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
                try await sync()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
