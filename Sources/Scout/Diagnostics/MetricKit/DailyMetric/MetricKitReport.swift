//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct MetricKitReport: Sendable {
    let readings: [DailyMetricReading]
    let appVersion: String?
    let window: DateInterval
}

extension MetricKitReport {
    func id(of reading: DailyMetricReading, installID: UUID) -> UUID {
        UUID(digesting: [
            installID.uuidString,
            reading.name,
            reading.category ?? "",
            appVersion ?? "",
            String(window.start.timeIntervalSince1970),
            String(window.end.timeIntervalSince1970),
        ])
    }

    func log(installID: UUID, context: NSManagedObjectContext) throws {
        for reading in readings {
            let metricID = id(of: reading, installID: installID)

            guard try context.existing(DailyMetricEntry.self, key: "metricID", id: metricID) == nil else {
                continue
            }

            let entry = context.insert(DailyMetricEntry.self)
            entry.metricID = metricID
            entry.name = reading.name
            entry.category = reading.category
            entry.value = reading.value
            entry.appVersion = appVersion
            entry.windowStart = window.start
            entry.date = window.end
        }

        try context.save()
    }
}
