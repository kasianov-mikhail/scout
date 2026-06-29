//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ReleaseHealth {
    static func build(versions: [Version], crashes: [Crash], sessions: [Session], range: Range<Date>) -> [ReleaseHealth] {
        var versionByLaunch: [UUID: String] = [:]
        var latestDate: [String: Date] = [:]

        for version in versions {
            if let launchID = version.launchID, let appVersion = version.appVersion {
                versionByLaunch[launchID] = appVersion

                if let date = version.date, date > (latestDate[appVersion] ?? .distantPast) {
                    latestDate[appVersion] = date
                }
            }
        }

        var sessionsByVersion: [String: [Session]] = [:]
        for session in sessions {
            if let launchID = session.launchID, let version = versionByLaunch[launchID] {
                sessionsByVersion[version, default: []].append(session)
            }
        }

        var crashesByVersion: [String: [Crash]] = [:]
        for crash in crashes {
            if let launchID = crash.launchID, let version = versionByLaunch[launchID] {
                crashesByVersion[version, default: []].append(crash)
            }
        }

        let totalSessions = sessionsByVersion.values.reduce(0) { $0 + sessionCount($1) }
        let releaseVersions = Set(sessionsByVersion.keys).union(crashesByVersion.keys)

        return releaseVersions.sorted {
            (latestDate[$0] ?? .distantPast) > (latestDate[$1] ?? .distantPast)
        }.map { version in
            let versionSessions = sessionsByVersion[version] ?? []
            let versionCrashes = crashesByVersion[version] ?? []
            let sessions = sessionCount(versionSessions)
            let crashedSessions = Set(versionCrashes.compactMap(\.sessionID)).count
            let installs = Set(versionSessions.compactMap(\.installID)).count
            let crashedInstalls = Set(versionCrashes.compactMap(\.installID)).count

            return ReleaseHealth(
                version: version,
                crashFreeSessions: crashFree(crashedSessions, of: sessions),
                crashFreeUsers: crashFree(crashedInstalls, of: installs),
                crashes: versionCrashes,
                sessions: sessions,
                adoption: totalSessions > 0 ? Double(sessions) / Double(totalSessions) : 0,
                trend: trend(of: versionCrashes, in: range)
            )
        }
    }

    private static func sessionCount(_ sessions: [Session]) -> Int {
        Set(sessions.compactMap(\.sessionID)).count
    }

    private static func crashFree(_ affected: Int, of total: Int) -> Double {
        guard total > 0 else { return 1 }
        return max(0, 1 - Double(affected) / Double(total))
    }

    private static func trend(of crashes: [Crash], in range: Range<Date>) -> [Int] {
        let slices = MiniChartSeries.sliceCount
        let span = range.upperBound.timeIntervalSince(range.lowerBound)

        guard span > 0 else {
            return Array(repeating: 0, count: slices)
        }

        let step = span / Double(slices)
        var values = Array(repeating: 0, count: slices)

        for crash in crashes {
            guard let date = crash.date, range.contains(date) else {
                continue
            }
            let index = min(slices - 1, Int(date.timeIntervalSince(range.lowerBound) / step))
            values[index] += 1
        }

        return values
    }
}
