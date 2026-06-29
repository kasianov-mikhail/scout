//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ReleaseHealth {
    static func summaries(versions: [Version], crashes: [Crash], sessions: [Session], range: Range<Date>) -> [ReleaseHealth] {
        var versionIndex: [UUID: String] = [:]
        for version in versions {
            if let launchID = version.launchID, let appVersion = version.appVersion {
                versionIndex[launchID] = appVersion
            }
        }

        var sessionsIndex: [String: [Session]] = [:]
        for session in sessions {
            if let launchID = session.launchID, let version = versionIndex[launchID] {
                sessionsIndex[version, default: []].append(session)
            }
        }

        var crashesIndex: [String: [Crash]] = [:]
        for crash in crashes {
            if let launchID = crash.launchID, let version = versionIndex[launchID] {
                crashesIndex[version, default: []].append(crash)
            }
        }

        let totalSessions = sessionsIndex.values.reduce(0) { $0 + sessionCount($1) }
        let releaseVersions = Set(sessionsIndex.keys).union(crashesIndex.keys).map { ReleaseVersion($0) }

        return releaseVersions.sorted().reversed().map { version in
            let versionSessions = sessionsIndex[version.version] ?? []
            let versionCrashes = crashesIndex[version.version] ?? []
            let sessions = sessionCount(versionSessions)
            let crashedSessions = Set(versionCrashes.compactMap(\.sessionID)).count
            let installs = Set(versionSessions.compactMap(\.installID)).count
            let crashedInstalls = Set(versionCrashes.compactMap(\.installID)).count

            return ReleaseHealth(
                version: version,
                crashFreeSessions: CrashFreeRate(affected: crashedSessions, total: sessions),
                crashFreeUsers: CrashFreeRate(affected: crashedInstalls, total: installs),
                crashes: versionCrashes,
                sessions: sessions,
                adoption: Adoption(totalSessions > 0 ? Double(sessions) / Double(totalSessions) : 0),
                trend: crashTrend(of: versionCrashes, in: range)
            )
        }
    }

    private static func sessionCount(_ sessions: [Session]) -> Int {
        Set(sessions.compactMap(\.sessionID)).count
    }
}
