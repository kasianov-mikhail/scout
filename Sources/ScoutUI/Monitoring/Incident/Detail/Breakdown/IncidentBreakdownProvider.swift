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

    var value: IncidentBreakdown? {
        if case .success(let value) = result {
            return value
        }
        return nil
    }

    private var deviceIDs: [UUID]
    private var sessionIDs: [UUID]
    private var modelsByDevice = ResolvedLabels()
    private var versionsBySession = ResolvedLabels()
    private var appVersionsBySession = ResolvedLabels()

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
        let missingSessions = Array(
            Set(versionsBySession.missing(ids: sessionIDs))
                .union(appVersionsBySession.missing(ids: sessionIDs))
        )

        async let models = IncidentLabelLookup<Device>(
            database: database,
            idField: "device_id",
            labelField: "model"
        )
        .labels(ids: missingDevices)

        async let sessions = IncidentLabelLookup<Session>(
            database: database,
            idField: "session_id",
            labelField: "os_version"
        )
        .labels(ids: missingSessions, fields: ["os_version", "app_version"])

        let foundModels = try await models
        let foundSessions = try await sessions

        modelsByDevice.merge(found: foundModels)
        versionsBySession.merge(found: foundSessions["os_version"] ?? ResolvedLabels())
        appVersionsBySession.merge(found: foundSessions["app_version"] ?? ResolvedLabels())

        let deviceModels = modelsByDevice.labels(ids: deviceIDs)
        let sessionVersions = versionsBySession.labels(ids: sessionIDs)
        let sessionAppVersions = appVersionsBySession.labels(ids: sessionIDs)

        return IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: Array(deviceModels.values)),
            osVersions: IncidentBreakdown.segments(from: Array(sessionVersions.values)),
            appVersions: IncidentBreakdown.segments(from: Array(sessionAppVersions.values)),
            modelsByDevice: deviceModels,
            appVersionsBySession: sessionAppVersions
        )
    }
}

struct ResolvedLabels {
    private var labels: [UUID: String] = [:]
    private var resolved: Set<UUID> = []

    func missing(ids: [UUID]) -> [UUID] {
        Array(Set(ids).subtracting(resolved))
    }

    mutating func resolve(id: UUID, label: String?) {
        resolved.insert(id)
        labels[id] = labels[id] ?? label
    }

    mutating func merge(found: ResolvedLabels) {
        labels.merge(found.labels) { _, new in new }
        resolved.formUnion(found.resolved)
    }

    func labels(ids: [UUID]) -> [UUID: String] {
        let wanted = Set(ids)
        return labels.filter { wanted.contains($0.key) }
    }
}
