//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ReleaseHealth {
    private struct Key: Hashable {
        let version: String
        let build: String
    }

    static func build(versions: [Version], crashes: [Crash], sessions: [Session], range: Range<Date>) -> [ReleaseHealth] {
        var keyByLaunch: [UUID: Key] = [:]
        var latestDate: [Key: Date] = [:]

        for version in versions {
            if let launchID = version.launchID, let appVersion = version.appVersion {
                let key = Key(version: appVersion, build: version.buildNumber ?? "")
                keyByLaunch[launchID] = key

                if let date = version.date, date > (latestDate[key] ?? .distantPast) {
                    latestDate[key] = date
                }
            }
        }

        var sessionsByKey: [Key: [Session]] = [:]
        for session in sessions {
            if let launchID = session.launchID, let key = keyByLaunch[launchID] {
                sessionsByKey[key, default: []].append(session)
            }
        }

        var crashesByKey: [Key: [Crash]] = [:]
        for crash in crashes {
            if let launchID = crash.launchID, let key = keyByLaunch[launchID] {
                crashesByKey[key, default: []].append(crash)
            }
        }

        let totalSessions = sessionsByKey.values.reduce(0) { $0 + sessionCount($1) }
        let keys = Set(sessionsByKey.keys).union(crashesByKey.keys)

        return keys.sorted {
            (latestDate[$0] ?? .distantPast) > (latestDate[$1] ?? .distantPast)
        }.map { key in
            let keySessions = sessionsByKey[key] ?? []
            let keyCrashes = crashesByKey[key] ?? []
            let sessions = sessionCount(keySessions)
            let crashedSessions = Set(keyCrashes.compactMap(\.sessionID)).count
            let installs = Set(keySessions.compactMap(\.installID)).count
            let crashedInstalls = Set(keyCrashes.compactMap(\.installID)).count

            return ReleaseHealth(
                version: key.version,
                build: key.build,
                crashFreeSessions: crashFree(crashedSessions, of: sessions),
                crashFreeUsers: crashFree(crashedInstalls, of: installs),
                crashes: keyCrashes,
                sessions: sessions,
                adoption: totalSessions > 0 ? Double(sessions) / Double(totalSessions) : 0,
                trend: trend(of: keyCrashes, in: range)
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
