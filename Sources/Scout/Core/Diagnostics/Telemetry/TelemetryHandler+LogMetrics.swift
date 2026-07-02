//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

extension CKTelemetryHandler {
    func logMetrics(telemetry: Telemetry.Export, value: some MetricScalar) {
        let label = self.label
        persistMetrics { context in
            try saveMetrics(label, date: Date(), category: telemetry.rawValue, value: value, context)
        }
    }

    func logTimer(seconds: TimeInterval) {
        let label = self.label
        persistMetrics { context in
            let date = Date()
            try saveMetrics(label, date: date, category: Telemetry.Export.timer.rawValue, value: seconds, context)
            try saveMetrics(label, date: date, category: LatencyBuckets.category(for: seconds), value: 1, context)
        }
    }

    private func persistMetrics(_ save: @escaping @Sendable (NSManagedObjectContext) throws -> Void) {
        let sync = self.sync
        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    try save(context)
                }
                try await sync()
            } catch {
                print("Failed to save metrics: \(error.localizedDescription)")
            }
        }
    }
}

func saveMetrics<T: MetricScalar>(_ name: String, date: Date, category: String, value: T, _ context: NSManagedObjectContext) throws {
    let entityName = String(describing: T.Object.self)
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
    let metrics = T.Object(entity: entity, insertInto: context)

    metrics.value = value
    metrics.telemetry = category
    metrics.date = date
    metrics.name = name

    try context.save()
}
