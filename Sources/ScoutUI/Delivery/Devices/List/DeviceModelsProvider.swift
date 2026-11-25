//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class DeviceModelsProvider: ObservableObject, Provider {
    typealias Output = [DeviceModelSummary]

    @Published var result: ProviderResult<[DeviceModelSummary]>?
    @Published private(set) var activities: [DeviceActivity] = []

    @Published var range: IncidentRange {
        didSet {
            if range != oldValue {
                loadedRange = nil
                result = nil
            }
        }
    }
    private(set) var activitiesRange: IncidentRange?

    private var loadedRange: IncidentRange?

    init(_ result: ProviderResult<[DeviceModelSummary]>? = nil, range: IncidentRange = .week) {
        self.range = range
        self.result = result
        self.loadedRange = result == nil ? nil : range
    }

    func load(in database: DatabaseReader) async {
        guard loadedRange != range else {
            return
        }
        let requested = range
        await fetchAgain(in: database)

        guard !Task.isCancelled, range == requested else {
            return
        }

        if case .success = result {
            loadedRange = requested
        }
    }

    func fetch(in database: DatabaseReader) async throws -> [DeviceModelSummary] {
        let requested = range
        let activities: [DeviceActivity]

        do {
            activities = try await database.devices(in: requested.range(now: Date()))
        } catch {
            try Task.checkCancellation()
            guard range == requested else {
                throw CancellationError()
            }
            throw error
        }

        try Task.checkCancellation()
        guard range == requested else {
            throw CancellationError()
        }

        self.activitiesRange = requested
        self.activities = activities

        return [DeviceModelSummary](activities: activities)
    }
}
