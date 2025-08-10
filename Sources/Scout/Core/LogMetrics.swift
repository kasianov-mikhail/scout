//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// Logs a metrics event with the specified name, date, and value.
///
/// This function creates a new `MetricsObject` instance, sets its name, date, and value,
/// and saves it to the provided Core Data context.
///
/// - Parameters:
///   - name: The name of the metrics event to log.
///   - date: The date and time when the metrics event occurred.
///   - telemetry: The telemetry type associated with the metrics event, represented by the `Telemetry.Export` enum.
///     This enum should be defined elsewhere in your codebase to represent different telemetry events.
///   - value: The numeric value associated with the metrics event.
///   - context: The Core Data context where the metrics event should be saved.
///
/// - Throws: An error if the metrics event could not be saved to the context.
///
func logMetrics(
    _ name: String,
    date: Date,
    telemetry: Telemetry.Export,
    value: Double,
    context: NSManagedObjectContext
) throws {
    let entity = NSEntityDescription.entity(forEntityName: "MetricsObject", in: context)!
    let metrics = MetricsObject(entity: entity, insertInto: context)

    metrics.value = value
    metrics.telemetry = telemetry.rawValue
    metrics.date = date
    metrics.name = name

    try context.save()
}
