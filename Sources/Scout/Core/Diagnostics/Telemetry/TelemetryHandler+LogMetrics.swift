//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension CKTelemetryHandler {
    func logMetrics<T: MetricScalar>(telemetry: Telemetry.Export, value: T) {
        let label = self.label
        let sync = self.sync
        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    try saveMetrics(
                        label,
                        date: Date(),
                        telemetry: telemetry,
                        value: value,
                        context
                    )
                }
                try await sync()
            } catch {
                print("Failed to save metrics: \(error.localizedDescription)")
            }
        }
    }
}

func saveMetrics<T: MetricScalar>(
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
