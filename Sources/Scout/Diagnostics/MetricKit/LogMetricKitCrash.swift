//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logMetricKitCrash(crash: MetricKitCrash, installID: UUID, context: NSManagedObjectContext) throws {
    let existing = NSFetchRequest<CrashEntry>(entityName: "CrashEntry")
    existing.predicate = NSPredicate(format: "crashID == %@", crash.id as CVarArg)

    guard try context.count(for: existing) == 0 else {
        return
    }

    let install = try context.existing(InstallEntry.self, key: "installID", id: installID)
    let launch = try install.flatMap { try crashedLaunch(crash: crash, install: $0, context: context) }

    if let launch, launch.sessions.contains(where: \.hasCrashes) {
        return
    }
    if launch == nil, crash.isCaughtInProcess {
        return
    }

    let entry = context.insert(CrashEntry.self)
    entry.crashID = crash.id
    entry.date = crash.date
    entry.appVersion = crash.appVersion
    entry.name = crash.name
    entry.fingerprint = crash.fingerprint
    entry.reason = crash.reason
    entry.stackTrace = try JSONEncoder().encode(crash.stackTrace)
    entry.session = try launch.flatMap { try lastSession(launch: $0, date: crash.date, context: context) }
    crash.source.apply(to: entry)

    try MarkerEntry.mark(name: MarkerEntry.crashName, install: install, appVersion: crash.appVersion, in: context)

    try context.save()
}

private func crashedLaunch(crash: MetricKitCrash, install: InstallEntry, context: NSManagedObjectContext) throws -> LaunchEntry? {
    guard let processID = crash.processID else {
        return nil
    }

    let request = NSFetchRequest<LaunchEntry>(entityName: "LaunchEntry")
    request.predicate = NSPredicate(
        format: "install == %@ AND processID == %d AND %K <= %@",
        install,
        processID,
        DateEntry.datePrimitiveKey,
        crash.date as NSDate
    )
    request.sortDescriptors = [NSSortDescriptor(key: DateEntry.datePrimitiveKey, ascending: false)]
    request.fetchLimit = 1
    return try context.fetch(request).first
}

private func lastSession(launch: LaunchEntry, date: Date, context: NSManagedObjectContext) throws -> SessionEntry? {
    let request = NSFetchRequest<SessionEntry>(entityName: "SessionEntry")
    request.predicate = NSPredicate(format: "launch == %@ AND %K <= %@", launch, DateEntry.datePrimitiveKey, date as NSDate)
    request.sortDescriptors = [NSSortDescriptor(key: DateEntry.datePrimitiveKey, ascending: false)]
    request.fetchLimit = 1
    return try context.fetch(request).first
}

extension SessionEntry {
    fileprivate var hasCrashes: Bool {
        !crashes.isEmpty
    }
}
