//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [DeviceHistoryEvent] {
    init(installs: [Install], versions: [Version], sessions: [Session]) {
        var events: [DeviceHistoryEvent] = []
        let sortedVersions = versions.sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        let versionsByInstall = Dictionary(grouping: sortedVersions, by: \.installID)
        let installedVersions = versionsByInstall.compactMapValues { $0.first?.appVersion }
        let firstVersionIDs = Set(versionsByInstall.values.compactMap { $0.first?.id })

        let datedInstalls =
            installs
            .filter { $0.date != nil }
            .sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        var isFirstInstall = true

        for install in datedInstalls {
            guard let date = install.date else {
                continue
            }
            let version = install.installID.flatMap { installedVersions[$0] }

            if isFirstInstall {
                events.append(DeviceHistoryEvent(id: "install-\(install.id)", date: date, kind: .installed(version: version)))
                isFirstInstall = false
            } else {
                events.append(DeviceHistoryEvent(id: "install-\(install.id)", date: date, kind: .reinstalled(version: version)))
            }
        }

        if datedInstalls.isEmpty, let first = sortedVersions.first, let date = first.date {
            events.append(DeviceHistoryEvent(id: "install-\(first.id)", date: date, kind: .installed(version: first.appVersion)))
        }

        for version in sortedVersions where !firstVersionIDs.contains(version.id) {
            guard let date = version.date, let appVersion = version.appVersion else {
                continue
            }
            events.append(DeviceHistoryEvent(id: "version-\(version.id)", date: date, kind: .updated(version: appVersion)))
        }

        var currentOS: String?

        for session in sessions.sorted(by: { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }) {
            guard let date = session.startDate, let osVersion = session.osVersion, !osVersion.isEmpty else {
                continue
            }
            if let currentOS, currentOS != osVersion {
                events.append(
                    DeviceHistoryEvent(
                        id: "os-\(date.timeIntervalSince1970)",
                        date: date,
                        kind: .os(from: currentOS, to: osVersion)
                    )
                )
            }
            currentOS = osVersion
        }

        self = events.sorted { $0.date > $1.date }
    }
}
