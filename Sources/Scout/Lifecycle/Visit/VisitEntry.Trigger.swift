//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

extension VisitEntry {
    struct Trigger: Command {
        let launchID: UUID
        var date: Date = Date()
        var appVersion: String? = Bundle.main.marketingVersion

        func execute(in context: NSManagedObjectContext) throws {
            let launch = try context.existing(LaunchEntry.self, key: "launchID", id: launchID)
            let device = launch?.install?.device

            if let device {
                guard device.lastVisitDay != date.startOfDay else {
                    return
                }
            } else {
                let request = NSFetchRequest<VisitEntry>(entityName: "VisitEntry")
                request.predicate = NSPredicate(format: "day == %@", date.startOfDay as NSDate)
                request.fetchLimit = 1

                guard try context.fetch(request).isEmpty else {
                    return
                }
            }

            let visit = context.insert(VisitEntry.self)
            visit.visitID = UUID()
            visit.date = date
            visit.launch = launch

            let gap = context.insert(VisitGapEntry.self)
            gap.date = date
            gap.gap = device?.visit(day: date.startOfDay) ?? Int16(VisitGapEntry.cap)
            gap.appVersion = appVersion
            gap.launch = launch

            try context.save()
        }
    }
}

extension DeviceEntry {
    fileprivate func visit(day: Date) -> Int16 {
        defer { lastVisitDay = day }

        guard let lastVisitDay else { return Int16(VisitGapEntry.cap) }

        let days = Calendar.utc.dateComponents([.day], from: lastVisitDay, to: day).day ?? VisitGapEntry.cap
        return Int16(min(max(days, 1), VisitGapEntry.cap))
    }
}
