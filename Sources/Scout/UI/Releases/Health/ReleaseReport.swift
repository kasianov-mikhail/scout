//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ReleaseReport {
    let sessionMatrices: [GridMatrix<Int>]
    let crashes: [Crash]
    let versions: [Version]
    let range: Range<Date>

    var releases: [ReleaseHealth] {
        let sessionCounts = sessionCounts
        let crashIndex = crashIndex

        let totalSessions = sessionCounts.values.reduce(0, +)

        let releaseVersions = Set(sessionCounts.keys)
            .union(crashIndex.keys)
            .map(ReleaseVersion.init)
            .sorted()
            .reversed()
            .map(\.version)

        return releaseVersions.map { version in
            ReleaseHealth(
                version: version,
                sessions: sessionCounts[version] ?? 0,
                crashes: crashIndex[version] ?? [],
                totalSessions: totalSessions,
                range: range
            )
        }
    }

    private var sessionCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for matrix in sessionMatrices {
            if let version = matrix.version {
                counts[version, default: 0] += matrix.points.filter { range.contains($0.date) }.total
            }
        }
        return counts
    }

    private var crashIndex: [String: [Crash]] {
        var versionIndex: [UUID: String] = [:]
        for version in versions {
            if let launchID = version.launchID, let appVersion = version.appVersion {
                versionIndex[launchID] = appVersion
            }
        }

        var index: [String: [Crash]] = [:]
        for crash in crashes {
            if let launchID = crash.launchID, let version = versionIndex[launchID] {
                index[version, default: []].append(crash)
            }
        }
        return index
    }
}

extension ReleaseHealth {
    init(version: String, sessions: Int, crashes versionCrashes: [Crash], totalSessions: Int, range: Range<Date>) {
        let crashedSessions = Set(versionCrashes.compactMap(\.sessionID)).count

        self.init(
            id: version,
            crashFreeSessions: CrashFreeRate(affected: crashedSessions, total: sessions),
            crashFreeUsers: nil,
            crashes: versionCrashes,
            sessions: sessions,
            adoption: Adoption(totalSessions > 0 ? Double(sessions) / Double(totalSessions) : 0),
            trend: crashTrend(of: versionCrashes, in: range)
        )
    }
}
