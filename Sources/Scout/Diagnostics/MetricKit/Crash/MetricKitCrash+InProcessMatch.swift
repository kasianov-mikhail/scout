//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

private let timestampTolerance: TimeInterval = 60

extension MetricKitCrash {
    func isCaughtInProcess(install: InstallEntry, context: NSManagedObjectContext) throws -> Bool {
        guard let inProcessNameMatch else {
            return false
        }

        let range = [
            window.start.addingTimeInterval(-timestampTolerance),
            window.end.addingTimeInterval(timestampTolerance),
        ]
        let scope = NSPredicate(
            format: "source == nil AND session.launch.install == %@ AND %K BETWEEN %@",
            install,
            DateEntry.datePrimitiveKey,
            range as NSArray
        )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scope, inProcessNameMatch])
        return try context.latest(type: CrashEntry.self, predicate: predicate) != nil
    }

    private var inProcessNameMatch: NSPredicate? {
        if let exception {
            NSPredicate(format: "name == %@", exception.name)
        } else if signal == SIGABRT {
            NSPredicate(value: true)
        } else if let signal, fatalSignals.contains(where: { $0.signal == signal }) {
            NSPredicate(format: "name == %@", signalName(signal))
        } else {
            nil
        }
    }
}
