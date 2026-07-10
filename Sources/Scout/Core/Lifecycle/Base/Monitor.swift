//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

protocol Monitor: PartialMonitor {
    static func complete(identity: Identity, in context: NSManagedObjectContext) throws
}

protocol PartialMonitor {
    static func trigger(identity: Identity, in context: NSManagedObjectContext) throws
}

protocol RecoveryMonitor {
    static func completeStale(identity: Identity, in context: NSManagedObjectContext) throws
}

enum MonitorError: LocalizedError, Equatable {
    case notFound
    case alreadyCompleted(Date)

    var errorDescription: String? {
        switch self {
        case .notFound:
            "MonitorError not found in the context"
        case .alreadyCompleted(let date):
            "MonitorError already completed on \(date)"
        }
    }

    static func == (lhs: MonitorError, rhs: MonitorError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound):
            true
        case (.alreadyCompleted, .alreadyCompleted):
            true
        default:
            false
        }
    }
}
