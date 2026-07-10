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
        logMetrics(category: telemetry.rawValue, value: value)
    }

    func logMetrics(category: String, value: some MetricScalar) {
        let label = self.label
        let sessionID = session.current
        persistMetrics { context in
            try saveMetrics(label, date: Date(), category: category, value: value, sessionID: sessionID, context)
        }
    }

    func logTimer(seconds: TimeInterval) {
        let label = self.label
        let sessionID = session.current
        persistMetrics { context in
            let date = Date()
            try saveMetrics(label, date: date, category: Telemetry.Export.timer.rawValue, value: seconds, sessionID: sessionID, context)
            try saveMetrics(label, date: date, category: LatencyBuckets.category(for: seconds), value: 1, sessionID: sessionID, context)
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

func saveMetrics<T: MetricScalar>(_ name: String, date: Date, category: String, value: T, sessionID: UUID, _ context: NSManagedObjectContext) throws {
    let metrics = context.insert(T.Object.self)

    metrics.value = value
    metrics.telemetry = category
    metrics.date = date
    metrics.name = name
    metrics.session = try context.existing(SessionObject.self, key: "sessionID", id: sessionID)

    try context.save()
}
