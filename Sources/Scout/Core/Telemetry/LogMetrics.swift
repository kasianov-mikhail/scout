//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logMetrics<T: MatrixValue>(
    _ name: String,
    telemetry: Telemetry.Export,
    value: T
) {
    Task {
        do {
            try await persistentContainer.performBackgroundTask { context in
                try logMetrics(
                    name,
                    date: Date(),
                    telemetry: telemetry,
                    value: value,
                    context
                )
            }
            try await SyncController.shared.synchronize()
        } catch {
            print("Failed to save metrics: \(error.localizedDescription)")
        }
    }
}

func logMetrics<T: MatrixValue>(
    _ name: String,
    date: Date,
    telemetry: Telemetry.Export,
    value: T,
    _ context: NSManagedObjectContext
) throws {
    let entityName = String(describing: T.Object.self)
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
    let metrics = T.Object(entity: entity, insertInto: context)

    metrics.value = value
    metrics.telemetry = telemetry.rawValue
    metrics.date = date
    metrics.name = name

    try context.save()
}
