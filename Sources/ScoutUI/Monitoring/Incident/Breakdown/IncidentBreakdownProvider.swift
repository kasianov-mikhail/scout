//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

@MainActor
final class IncidentBreakdownProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<IncidentBreakdown>?

    private var deviceIDs: [UUID]
    private var sessionIDs: [UUID]
    private var modelsByDevice = ResolvedLabels()
    private var versionsBySession = ResolvedLabels()

    init(_ result: ProviderResult<Output>? = nil, deviceIDs: [UUID], sessionIDs: [UUID]) {
        self.deviceIDs = deviceIDs
        self.sessionIDs = sessionIDs
        self.result = result
    }

    func fetch(deviceIDs: [UUID], sessionIDs: [UUID], in database: DatabaseReader) async {
        let unchanged = Set(deviceIDs) == Set(self.deviceIDs) && Set(sessionIDs) == Set(self.sessionIDs)

        guard result == nil || !unchanged else {
            return
        }

        self.deviceIDs = deviceIDs
        self.sessionIDs = sessionIDs
        await fetchLatest(in: database)
    }

    func fetch(in database: RecordReader) async throws -> IncidentBreakdown {
        let missingDevices = modelsByDevice.missing(ids: deviceIDs)
        let missingSessions = versionsBySession.missing(ids: sessionIDs)

        async let models = IncidentLabelLookup<Device>(
            database: database,
            idField: "device_id",
            labelField: "model"
        )
        .labels(ids: missingDevices)

        async let versions = IncidentLabelLookup<Session>(
            database: database,
            idField: "session_id",
            labelField: "os_version"
        )
        .labels(ids: missingSessions)

        let foundModels = try await models
        let foundVersions = try await versions

        modelsByDevice.merge(found: foundModels, ids: missingDevices)
        versionsBySession.merge(found: foundVersions, ids: missingSessions)

        let deviceModels = modelsByDevice.labels(ids: deviceIDs)
        let sessionVersions = versionsBySession.labels(ids: sessionIDs)

        return IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: Array(deviceModels.values)),
            osVersions: IncidentBreakdown.segments(from: Array(sessionVersions.values)),
            modelsByDevice: deviceModels,
            versionsBySession: sessionVersions
        )
    }
}

private struct ResolvedLabels {
    private var labels: [UUID: String] = [:]
    private var resolved: Set<UUID> = []

    func missing(ids: [UUID]) -> [UUID] {
        Array(Set(ids).subtracting(resolved))
    }

    mutating func merge(found: [UUID: String], ids: [UUID]) {
        labels.merge(found) { _, new in new }
        resolved.formUnion(ids)
    }

    func labels(ids: [UUID]) -> [UUID: String] {
        let wanted = Set(ids)
        return labels.filter { wanted.contains($0.key) }
    }
}
