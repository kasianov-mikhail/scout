//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class SessionInfoProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<SessionInfo>?

    private let sessionID: UUID
    private let deviceID: UUID?

    init(sessionID: UUID, deviceID: UUID?) {
        self.sessionID = sessionID
        self.deviceID = deviceID
    }

    func fetch(in database: DatabaseReader) async throws -> SessionInfo {
        let session = try await database.lookup(
            recordName: sessionID.uuidString,
            fields: ["app_version", "build_number", "os_version", "locale", "channel", "start_date", "end_date"]
        )

        let model = try await deviceModel(in: database)

        return SessionInfo(
            model: model,
            osVersion: session["os_version"],
            locale: session["locale"],
            channel: session["channel"],
            appVersion: session["app_version"],
            buildNumber: session["build_number"],
            startDate: session["start_date"],
            endDate: session["end_date"]
        )
    }

    private func deviceModel(in database: DatabaseReader) async throws -> String? {
        guard let deviceID else { return nil }
        let device = try? await database.lookup(recordName: deviceID.uuidString, fields: ["model"])
        return device?["model"]
    }
}
