//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logMetricKitCrash(crash: MetricKitCrash, installID: UUID, context: NSManagedObjectContext) throws {
    let install = try context.existing(InstallEntry.self, key: "installID", id: installID)
    let launch = try install.flatMap { try crashedLaunch(crash: crash, install: $0, context: context) }

    if let launch, launch.sessions.contains(where: \.hasCrashes) {
        return
    }
    if launch == nil, crash.isCaughtInProcess {
        return
    }

    guard let entry = try context.insertIncident(type: CrashEntry.self, content: crash, idKey: "crashID", id: crash.id) else {
        return
    }
    entry.session = try launch.flatMap { try lastSession(launch: $0, date: crash.date, context: context) }
    crash.source.apply(to: entry)

    try MarkerEntry.mark(name: MarkerEntry.crashName, install: install, appVersion: crash.appVersion, in: context)

    try context.save()
}

private func crashedLaunch(crash: MetricKitCrash, install: InstallEntry, context: NSManagedObjectContext) throws -> LaunchEntry? {
    guard let processID = crash.processID else {
        return nil
    }

    let predicate = NSPredicate(
        format: "install == %@ AND processID == %d AND %K <= %@",
        install,
        processID,
        DateEntry.datePrimitiveKey,
        crash.date as NSDate
    )
    return try context.latest(type: LaunchEntry.self, predicate: predicate)
}

private func lastSession(launch: LaunchEntry, date: Date, context: NSManagedObjectContext) throws -> SessionEntry? {
    let predicate = NSPredicate(format: "launch == %@ AND %K <= %@", launch, DateEntry.datePrimitiveKey, date as NSDate)
    return try context.latest(type: SessionEntry.self, predicate: predicate)
}

extension SessionEntry {
    fileprivate var hasCrashes: Bool {
        !crashes.isEmpty
    }
}
