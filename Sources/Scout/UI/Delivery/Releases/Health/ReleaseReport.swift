//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

typealias IntMatrices = [GridMatrix<Int>]

struct ReleaseMatrices {
    let sessions: IntMatrices
    let crashes: IntMatrices
    let hangs: IntMatrices
    let installs: IntMatrices
    let crashedInstalls: IntMatrices

    func report(in range: Range<Date>) -> [ReleaseHealth] {
        let sessionCounts = sessions.points(in: range).mapValues(\.total)
        let crashPoints = crashes.points(in: range)
        let hangCounts = hangs.points(in: range).mapValues(\.total)
        let installCounts = installs.points(in: range).mapValues(\.total)
        let crashedInstallCounts = crashedInstalls.points(in: range).mapValues(\.total)

        let versions = Set(sessionCounts.keys)
            .union(crashPoints.keys)
            .union(installCounts.keys)
            .sorted(by: versionDescending)

        let totalSessions = sessionCounts.values.reduce(0, +)

        return versions.map { version in
            let sessions = sessionCounts[version] ?? 0
            let crashPoints = crashPoints[version] ?? []
            let crashes = crashPoints.total
            let installs = installCounts[version] ?? 0

            return ReleaseHealth(
                id: version,
                freeSessions: Stability(of: crashes, in: sessions),
                freeUsers: Stability.optional(of: crashedInstallCounts[version] ?? 0, in: installs),
                crashes: crashes,
                hangs: hangCounts[version] ?? 0,
                sessions: sessions,
                adoption: Adoption(of: sessions, in: totalSessions),
                trend: crashPoints.trend(in: range)
            )
        }
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
