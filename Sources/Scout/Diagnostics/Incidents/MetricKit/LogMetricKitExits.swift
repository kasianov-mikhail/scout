//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logMetricKitExits(exits: MetricKitExits, installID: UUID, context: NSManagedObjectContext) throws {
    for (reason, count) in exits.counts {
        let metricID = exits.id(of: reason, installID: installID)

        guard try context.existing(DailyMetricEntry.self, key: "metricID", id: metricID) == nil else {
            continue
        }

        let entry = context.insert(DailyMetricEntry.self)
        entry.metricID = metricID
        entry.name = ExitReason.metricName
        entry.category = reason.rawValue
        entry.value = count
        entry.appVersion = exits.appVersion
        entry.windowStart = exits.window.start
        entry.date = exits.window.end
    }

    try context.save()
}
