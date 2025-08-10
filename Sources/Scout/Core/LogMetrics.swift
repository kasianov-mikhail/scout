//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// Logs metrics in the background and then triggers sync.
///
/// - Parameters:
///   - name: The name of the metric.
///   - telemetry: The telemetry type associated with the metric.
///   - value: The value of the metric.
///
func logMetrics(
    _ name: String,
    telemetry: Telemetry.Export,
    value: Double
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
            try await sync(in: container)
        } catch {
            print("Failed to save metrics: \(error.localizedDescription)")
        }
    }
}

/// Inserts metrics into the given Core Data context and saves.
///
/// - Parameters:
///   - name: The name of the metric.
///   - date: The date when the metric was recorded.
///   - telemetry: The telemetry type associated with the metric.
///   - value: The value of the metric.
///   - context: The Core Data context where the metric will be saved.
///
/// - Throws: An error if the insertion or saving fails.
///
func logMetrics(
    _ name: String,
    date: Date,
    telemetry: Telemetry.Export,
    value: Double,
    _ context: NSManagedObjectContext
) throws {
    let entity = NSEntityDescription.entity(forEntityName: "MetricsObject", in: context)!

    let metrics = MetricsObject(entity: entity, insertInto: context)
    metrics.value = value
    metrics.telemetry = telemetry.rawValue
    metrics.date = date
    metrics.name = name

    try context.save()
}
