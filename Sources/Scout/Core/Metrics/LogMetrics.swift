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
            try await sync(in: container)
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
    let metrics = T.Object(value: value, in: context)
    metrics.telemetry = telemetry.rawValue
    metrics.date = date
    metrics.name = name
    try context.save()
}
