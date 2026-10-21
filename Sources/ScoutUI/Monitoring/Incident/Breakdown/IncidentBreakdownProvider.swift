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
        async let models = IncidentLabelLookup<Device>(
            database: database,
            idField: "device_id",
            labelField: "model"
        )
        .labels(ids: deviceIDs)

        async let versions = IncidentLabelLookup<Session>(
            database: database,
            idField: "session_id",
            labelField: "os_version"
        )
        .labels(ids: sessionIDs)

        return try await IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: Array(models.values)),
            osVersions: IncidentBreakdown.segments(from: Array(versions.values)),
            modelsByDevice: models,
            versionsBySession: versions
        )
    }
}
