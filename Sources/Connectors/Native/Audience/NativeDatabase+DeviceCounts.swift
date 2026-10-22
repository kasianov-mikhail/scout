//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension NativeDatabase {
    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        let store = try await resolve()
        let windows = ranges.compactMap(\.gapWindow)

        guard windows.count == ranges.count else {
            return try await store.sessionDeviceCounts(in: ranges)
        }
        guard let lower = windows.map(\.lowerBound).min() else {
            return []
        }
        guard let upper = windows.map(\.upperBound).max() else {
            return []
        }

        let fold = try await store.visitGapFold(in: lower..<upper)
        var counts = windows.map(fold.devices)
        let unstamped = counts.indices.filter { counts[$0] == nil }
        let fallback = try await store.sessionDeviceCounts(in: unstamped.map { ranges[$0] })

        for (index, count) in zip(unstamped, fallback) {
            counts[index] = count
        }
        return counts.compactMap(\.self)
    }
}

extension EntityStore {
    fileprivate func visitGapFold(in range: Range<Date>) async throws -> VisitGapFold {
        async let gaps = query(VisitGapEntry.recordType).series(
            metric: .sum,
            group: "gap",
            in: range
        )
        async let versions = query(VisitGapEntry.recordType).series(
            metric: .sum,
            group: "app_version",
            in: range
        )
        async let sessions = query(SessionEntry.recordType).series(
            metric: .sum,
            group: CatalogEntry.lifecycleKey,
            in: range
        )

        return try await VisitGapFold(gaps: gaps, versions: versions, sessions: sessions)
    }

    fileprivate func sessionDeviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        guard let lower = ranges.map(\.lowerBound).min() else {
            return []
        }
        guard let upper = ranges.map(\.upperBound).max() else {
            return []
        }

        let points = try await query(SessionEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: lower..<upper
        )

        return ranges.map { range in
            Set(points.filter { range.contains($0.date) }.map(\.group)).count
        }
    }
}

extension Range<Date> {
    fileprivate var gapWindow: Range<Date>? {
        let length = upperBound.timeIntervalSince(lowerBound)

        guard length >= .day, length <= TimeInterval(VisitGapEntry.cap + 1) * .day else {
            return nil
        }
        return Swift.max(lowerBound, upperBound.addingDay(-VisitGapEntry.cap))..<upperBound
    }
}
