//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

func releaseReport(sessions: [GridMatrix<Int>], crashes: [GridMatrix<Int>], range: Range<Date>) -> [ReleaseHealth] {
    let sessionCounts = sessions.points(in: range).mapValues(\.total)
    let crashPoints = crashes.points(in: range)
    let totalSessions = sessionCounts.values.reduce(0, +)

    let versions = Set(sessionCounts.keys)
        .union(crashPoints.keys)
        .sorted(by: versionDescending)

    return versions.map { version in
        let sessions = sessionCounts[version] ?? 0
        let crashPoints = crashPoints[version] ?? []
        let crashes = crashPoints.total

        return ReleaseHealth(
            id: version,
            freeSessions: Stability(of: crashes, in: sessions),
            freeUsers: nil,
            crashes: crashes,
            sessions: sessions,
            adoption: Adoption(of: sessions, in: totalSessions),
            trend: crashPoints.trend(in: range)
        )
    }
}

extension [GridMatrix<Int>] {
    fileprivate func points(in range: Range<Date>) -> [String: [ChartPoint<Int>]] {
        var result: [String: [ChartPoint<Int>]] = [:]
        for matrix in self {
            if let version = matrix.version {
                result[version, default: []] += matrix.points.filter { range.contains($0.date) }
            }
        }
        return result
    }
}

extension [ChartPoint<Int>] {
    fileprivate func trend(in range: Range<Date>) -> [Int] {
        let slices = MiniChartSeries.sliceCount
        var values = [Int](repeating: 0, count: slices)
        let span = range.upperBound.timeIntervalSince(range.lowerBound)

        guard span > 0 else {
            return values
        }

        let step = span / Double(slices)

        for point in self where range.contains(point.date) {
            let index = Swift.min(slices - 1, Int(point.date.timeIntervalSince(range.lowerBound) / step))
            values[index] += point.count
        }

        return values
    }
}

private func versionDescending(_ lhs: String, _ rhs: String) -> Bool {
    let lhsParts = lhs.split(separator: ".").map { Int($0) ?? 0 }
    let rhsParts = rhs.split(separator: ".").map { Int($0) ?? 0 }

    for index in 0..<max(lhsParts.count, rhsParts.count) {
        let left = index < lhsParts.count ? lhsParts[index] : 0
        let right = index < rhsParts.count ? rhsParts[index] : 0
        if left != right {
            return left > right
        }
    }

    return lhs > rhs
}
