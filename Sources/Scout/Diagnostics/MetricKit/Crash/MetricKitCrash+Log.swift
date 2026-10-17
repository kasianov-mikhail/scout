//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MetricKitCrash {
    func log(installID: UUID, context: NSManagedObjectContext) throws {
        let install = try context.existing(InstallEntry.self, key: "installID", id: installID)
        let launch = try install.flatMap { try launch(install: $0, context: context) }

        if let launch, launch.sessions.contains(where: \.hasCrashes) {
            return
        }
        if launch == nil, isCaughtInProcess {
            return
        }

        guard let entry = try context.insertIncident(type: CrashEntry.self, content: self, idKey: "crashID", id: id) else {
            return
        }
        entry.session = try launch?.lastSession(date: date, context: context)
        source.apply(to: entry)

        try MarkerEntry.mark(name: MarkerEntry.crashName, install: install, appVersion: appVersion, in: context)

        try context.save()
    }

    private func launch(install: InstallEntry, context: NSManagedObjectContext) throws -> LaunchEntry? {
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
    fileprivate func lastSession(date: Date, context: NSManagedObjectContext) throws -> SessionEntry? {
        let predicate = NSPredicate(format: "launch == %@ AND %K <= %@", self, DateEntry.datePrimitiveKey, date as NSDate)
        return try context.latest(type: SessionEntry.self, predicate: predicate)
    }
}

extension SessionEntry {
    fileprivate var hasCrashes: Bool {
        !crashes.isEmpty
    }
}
