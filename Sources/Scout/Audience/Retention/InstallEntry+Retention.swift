//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension InstallEntry {
    func startCohort() {
        osVersion = SystemInfo.osVersion
    }

    func markInstall() throws {
        guard cohortDay != nil, let date else {
            return
        }
        try mark(milestone: .install, date: date)
    }

    func markVisit(date: Date) throws {
        guard let start = cohortDay else {
            return
        }
        guard let offset = RetentionCohort.dayOffsets.first(where: { start.addingDay($0) == date.startOfDay }) else {
            return
        }
        try mark(milestone: .day(offset), date: date)
    }

    func markIncident(milestone: RetentionMilestone, date: Date?) throws {
        guard let start = cohortDay, let date else {
            return
        }
        guard (start..<start.addingDay(RetentionCohort.horizon)).contains(date) else {
            return
        }
        try mark(milestone: milestone, date: date)
    }

    private var cohortDay: Date? {
        osVersion == nil ? nil : date?.startOfDay
    }

    private func mark(milestone: RetentionMilestone, date: Date) throws {
        guard let context = managedObjectContext else {
            return
        }

        let request = NSFetchRequest<RetentionMarkEntry>(entityName: "RetentionMarkEntry")
        request.predicate = NSPredicate(format: "install == %@ AND name == %@", self, milestone.name)
        request.fetchLimit = 1

        guard try context.count(for: request) == 0 else {
            return
        }

        let mark = context.insert(RetentionMarkEntry.self)
        mark.name = milestone.name
        mark.date = date
        mark.install = self
    }
}
