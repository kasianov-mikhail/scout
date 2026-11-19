//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoScenario {
    struct AppVersion {
        let version: String
        let build: String
        let releasedDaysAgo: Int
    }

    struct DeviceInfo {
        let id: UUID
        let model: String
        let os: String
    }

    struct InstallInfo {
        let id: UUID
        let device: DeviceInfo
        let date: Date
        let locale: String
        let channel: String
    }

    struct SessionInfo {
        let id: UUID
        let install: InstallInfo
        let launchID: UUID
        let start: Date
        let end: Date
        let version: AppVersion

        var device: DeviceInfo { install.device }

        func versioned(_ record: Record) -> Record {
            var record = record
            record["app_version"] = version.version
            return record
        }
    }

    static let installCount = 2400
    static let spanDays = 120

    let clock: DemoClock
    let versions: [AppVersion]
    let installs: [InstallInfo]
    let sessions: [SessionInfo]

    var adoption: [(version: String, date: Date)] {
        var seen: Set<String> = []
        return sessions.compactMap { session in
            guard seen.insert("\(session.install.id)-\(session.version.version)").inserted else {
                return nil
            }
            return (session.version.version, session.start)
        }
    }
}
