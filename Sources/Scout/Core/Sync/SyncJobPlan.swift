//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

struct SyncJobPlan: Sendable {
    typealias Job = () async throws -> Void

    let engine: SyncEngine

    var jobs: [Job] {
        [
            { try await engine.send(type: EventObject.self) },
            { try await engine.send(type: SessionObject.self) },
            { try await engine.send(type: UserActivity.self) },
            { try await engine.send(type: IntMetricsObject.self) },
            { try await engine.send(type: DoubleMetricsObject.self) },
        ]
    }
}
