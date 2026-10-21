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
        let launch = try install.flatMap { try processLaunch(install: $0, context: context) }

        if let launch, launch.scopedEntries.contains(where: { ($0 as? SessionEntry)?.hasCrashes == true }) {
            return
        }
        if launch == nil, let install, try isCaughtInProcess(install: install, context: context) {
            return
        }

        guard let entry = try context.insertIncident(type: CrashEntry.self, content: self, idKey: "crashID", id: id) else {
            return
        }
        entry.session = try launch?.lastSession(date: date, context: context)
        entry.install = install
        source.apply(to: entry)
        entry.threads = threads.isEmpty ? nil : try JSONEncoder().encode(threads)

        try install?.mark(name: Version.crashMarker, appVersion: appVersion)
        try install?.markIncident(milestone: .crash, date: date)

        try context.save()
    }
}

extension SessionEntry {
    fileprivate var hasCrashes: Bool {
        scopedEntries.contains { $0 is CrashEntry }
    }
}
