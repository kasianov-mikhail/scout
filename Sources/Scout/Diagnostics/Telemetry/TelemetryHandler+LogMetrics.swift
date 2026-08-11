//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

extension TelemetryPersisting {
    func logMetrics(telemetry: Telemetry.Export, value: some MetricScalar) {
        logMetrics(category: telemetry.rawValue, value: value)
    }

    func logMetrics(category: String, value: some MetricScalar) {
        let label = self.label
        let date = Date()
        let sessionID = runtime.session.current
        persistMetrics { context in
            try saveMetrics(label, date: date, category: category, value: value, sessionID: sessionID, context)
        }
    }

    func logTimer(seconds: TimeInterval) {
        let label = self.label
        let date = Date()
        let sessionID = runtime.session.current
        persistMetrics { context in
            try saveMetrics(
                label, date: date, category: Telemetry.Export.timer.rawValue, value: seconds, sessionID: sessionID,
                context)
            try saveMetrics(
                label, date: date, category: LatencyBuckets.category(for: seconds), value: 1, sessionID: sessionID,
                context)
        }
    }

    func logMeter(value: Double) {
        logMetrics(telemetry: .meter, value: value)
    }

    func logRecorder(value: Double) {
        let label = self.label
        let date = Date()
        let sessionID = runtime.session.current
        persistMetrics { context in
            try saveMetrics(
                label, date: date, category: Telemetry.Export.recorder.rawValue, value: value, sessionID: sessionID,
                context)
            try saveMetrics(
                label, date: date, category: RecorderBuckets.category(for: value), value: 1, sessionID: sessionID,
                context)
        }
    }

    private func persistMetrics(_ save: @escaping @Sendable (NSManagedObjectContext) throws -> Void) {
        let sync = runtime.sync
        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    try save(context)
                }
                try await sync()
            } catch {
                print("Failed to save metrics: \(error)")
            }
        }
    }
}

func saveMetrics<T: MetricScalar>(
    _ name: String, date: Date, category: String, value: T, sessionID: UUID, _ context: NSManagedObjectContext
) throws {
    let metrics = context.insert(T.Object.self)

    metrics.value = value
    metrics.telemetry = category
    metrics.date = date
    metrics.name = name
    metrics.session = try context.existing(SessionEntry.self, key: "sessionID", id: sessionID)

    try context.save()
}
