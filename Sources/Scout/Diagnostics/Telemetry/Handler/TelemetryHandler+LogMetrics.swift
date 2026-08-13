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
        guard runtime.isEnabled else {
            return
        }

        let label = self.label
        let date = Date()
        let identity = runtime.identity.snapshot
        persistMetrics { context in
            try saveMetrics(label, date: date, category: category, value: value, identity: identity, context)
        }
    }

    func logTimer(seconds: TimeInterval) {
        guard runtime.isEnabled else {
            return
        }

        let label = self.label
        let date = Date()
        let identity = runtime.identity.snapshot
        persistMetrics { context in
            try saveMetrics(
                label, date: date, category: Telemetry.Export.timer.rawValue, value: seconds, identity: identity,
                context)
            try saveMetrics(
                label, date: date, category: LatencyBuckets.category(for: seconds), value: 1, identity: identity,
                context)
        }
    }

    func logMeter(value: Double) {
        logMetrics(telemetry: .meter, value: value)
    }

    func logRecorder(value: Double) {
        guard runtime.isEnabled else {
            return
        }

        let label = self.label
        let date = Date()
        let identity = runtime.identity.snapshot
        persistMetrics { context in
            try saveMetrics(
                label, date: date, category: Telemetry.Export.recorder.rawValue, value: value, identity: identity,
                context)
            try saveMetrics(
                label, date: date, category: RecorderBuckets.category(for: value), value: 1, identity: identity,
                context)
        }
    }

    private func persistMetrics(_ save: @escaping @Sendable (NSManagedObjectContext) throws -> Void) {
        let sync = runtime.sync

        Task {
            do {
                try await persistentContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergePolicy.scout
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
    _ name: String, date: Date, category: String, value: T, identity: Identity.Snapshot,
    _ context: NSManagedObjectContext
) throws {
    let metrics = context.insert(T.Object.self)

    metrics.value = value
    metrics.telemetry = category
    metrics.date = date
    metrics.name = name
    metrics.session = try context.linkedSession(identity, date: date)

    try context.save()
}
