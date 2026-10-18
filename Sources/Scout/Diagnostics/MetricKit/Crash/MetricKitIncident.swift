//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MetricKitIncident: IncidentContent, Sendable {
    var processID: Int32? { get }
    var window: DateInterval { get }
    var frames: [MetricKitStackTree.Frame] { get }

    func log(installID: UUID, context: NSManagedObjectContext) throws
}

extension MetricKitIncident {
    var stackTrace: [String] {
        frames.stackTrace
    }

    var backtrace: Backtrace? {
        Backtrace(stacks: [frames], attributed: 0)
    }

    var fingerprint: String {
        CrashFingerprint(name: name, offsets: frames.map { "\($0.binary) + \($0.offset)" }).value
    }

    var source: IncidentSource {
        .metricKit(windowStart: window.duration > 0 ? window.start : nil)
    }

    var date: Date {
        window.end
    }

    func processLaunch(install: InstallEntry, context: NSManagedObjectContext) throws -> LaunchEntry? {
        guard let processID else {
            return nil
        }

        let predicate = NSPredicate(
            format: "install == %@ AND processID == %d AND %K <= %@",
            install,
            processID,
            DateEntry.datePrimitiveKey,
            date as NSDate
        )
        return try context.latest(type: LaunchEntry.self, predicate: predicate)
    }
}

extension LaunchEntry {
    func lastSession(date: Date, context: NSManagedObjectContext) throws -> SessionEntry? {
        let predicate = NSPredicate(format: "launch == %@ AND %K <= %@", self, DateEntry.datePrimitiveKey, date as NSDate)
        return try context.latest(type: SessionEntry.self, predicate: predicate)
    }
}
