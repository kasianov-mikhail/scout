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

        var sessionIndex: [String: [Session]] = [:]
        for session in sessions {
            if let launchID = session.launchID, let version = versionIndex[launchID] {
                sessionIndex[version, default: []].append(session)
            }
        }

        var crashIndex: [String: [Crash]] = [:]
        for crash in crashes {
            if let launchID = crash.launchID, let version = versionIndex[launchID] {
                crashIndex[version, default: []].append(crash)
            }
        }

        let totalSessions = sessionIndex.values.reduce(0) { $0 + sessionCount($1) }
        let releaseVersions = Set(sessionIndex.keys).union(crashIndex.keys).map { ReleaseVersion($0) }

        return releaseVersions.sorted().reversed().map { version in
            ReleaseHealth(
                version: version,
                sessions: sessionIndex[version.version] ?? [],
                crashes: crashIndex[version.version] ?? [],
                totalSessions: totalSessions,
                range: range
            )
        }
    }

    private static func sessionCount(_ sessions: [Session]) -> Int {
        Set(sessions.compactMap(\.sessionID)).count
    }
}

extension ReleaseHealth {
    init(version: ReleaseVersion, sessions versionSessions: [Session], crashes versionCrashes: [Crash], totalSessions: Int, range: Range<Date>) {
        let sessions = Self.sessionCount(versionSessions)
        let crashedSessions = Set(versionCrashes.compactMap(\.sessionID)).count
        let installs = Set(versionSessions.compactMap(\.installID)).count
        let crashedInstalls = Set(versionCrashes.compactMap(\.installID)).count

        self.init(
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
