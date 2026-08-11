//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Logging

struct ScoutLogHandler: LogHandler {
    let runtime: Runtime
    let label: String

    var metadata: Logger.Metadata = [:]

    var logLevel: Logger.Level = .info

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    func log(event: LogEvent) {
        let sessionID = runtime.session.current
        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    try Scout.log(event, date: Date(), sessionID: sessionID, context: context)
                }
                try await self.runtime.sync()
            } catch {
                print("Failed to save log: \(error)")
            }
        }
    }
}
