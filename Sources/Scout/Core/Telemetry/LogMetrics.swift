//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logMetrics(
    _ name: String,
    telemetry: Telemetry.Export,
    intValue: Int64 = 0,
    doubleValue: Double = 0,
) {
    Task {
        do {
            try await persistentContainer.performBackgroundTask { context in
                try logMetrics(
                    name,
                    date: Date(),
                    telemetry: telemetry,
                    intValue: intValue,
                    doubleValue: doubleValue,
                    context
                )
            }
            try await sync(in: container)
        } catch {
            print("Failed to save metrics: \(error.localizedDescription)")
        }
    }
}

func logMetrics(
    _ name: String,
    date: Date,
    telemetry: Telemetry.Export,
    intValue: Int64,
    doubleValue: Double,
    _ context: NSManagedObjectContext
) throws {
    let entity = NSEntityDescription.entity(forEntityName: "MetricsObject", in: context)!

    let metrics = MetricsObject(entity: entity, insertInto: context)
    metrics.intValue = intValue
    metrics.doubleValue = doubleValue
    metrics.telemetry = telemetry.rawValue
    metrics.date = date
    metrics.name = name

    try context.save()
}
