//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct VersionSummary {
    let release: ReleaseHealth
    let trend: VersionTrend
    let now: Date

    init(release: ReleaseHealth, trend: VersionTrend, now: Date = Date()) {
        self.release = release
        self.trend = trend
        self.now = now
    }
}

extension VersionSummary {
    var level: Stability.Level {
        release.freeSessions.level
    }

    var statusLine: String {
        "\(level.displayTitle) · \(release.freeSessions.formatted) crash-free"
    }

    var adoptionLine: String {
        let line = "\(release.adoption.formatted) of sessions"

        guard let shippedAt = release.shipped else {
            return line
        }

        let days = Calendar.utc.dateComponents([.day], from: shippedAt.startOfDay, to: now.startOfDay).day ?? 0
        return "\(line) · day \(days)"
    }

    var shippedDate: String? {
        release.shipped.map { DateFormatter.monthDay.string(from: $0).uppercased() }
    }
}

extension VersionSummary {
    var crashes: [Int] {
        trend.crashes.map(\.count)
    }

    var hangs: [Int] {
        trend.hangs.map(\.count)
    }

    var resources: [Int] {
        trend.resources.map(\.count)
    }

    var crashesToday: Int {
        trend.crashes.last?.count ?? 0
    }

    var hangsToday: Int {
        trend.hangs.last?.count ?? 0
    }

    var resourcesToday: Int {
        trend.resources.last?.count ?? 0
    }

    var freeUsersNote: String {
        release.freeUsers.map { "users \($0.formatted)" } ?? "users –"
    }

    var sessionsNote: String {
        "\(release.sessions.compact) sessions"
    }

    var resourcesNote: String {
        let items = release.resources.readouts.filter { $0.value > 0 }
        let detail = items.map { "\($0.title.lowercasedAbbreviation) \($0.value)" }.joined(separator: ", ")

        guard !detail.isEmpty else {
            return "\(resourcesToday) today"
        }

        return "\(resourcesToday) today · \(detail)"
    }
}

extension VersionSummary {
    var launchBars: [Int] {
        release.performance.current.launchHistogram.counts.recentFourteen
    }

    var peakMemoryBars: [Int] {
        release.performance.current.memoryHistogram.counts.recentFourteen
    }

    var launchValue: String {
        readout(index: 0).value ?? "–"
    }

    var launchNote: String {
        note(readout: readout(index: 0))
    }

    var peakMemoryValue: String {
        readout(index: 2).value ?? "–"
    }

    var peakMemoryNote: String {
        note(readout: readout(index: 2))
    }

    var hangRateChange: Double? {
        readout(index: 1).change
    }

    var hangRateText: String {
        guard let value = readout(index: 1).value else {
            return "–"
        }

        guard let change = readout(index: 1).change else {
            return value
        }

        return "\(value) · \(Self.percent(change: change))"
    }

    var exitShares: [ExitShare] {
        release.exits.abnormal
    }

    var exitsPerMille: String {
        String(format: "%.1f ‰", release.exits.abnormalPerMille)
    }

    var topExitNote: String {
        release.exits.abnormal.first.map { "\($0.reason.title.lowercasedAbbreviation) \($0.formatted)" } ?? ""
    }
}

extension VersionSummary {
    static func percent(change: Double) -> String {
        let points = Int((change * 100).rounded())

        guard points != 0 else {
            return "±0%"
        }

        return points > 0 ? "+\(points)%" : "−\(-points)%"
    }

    private func readout(index: Int) -> PerformanceReadout {
        release.performance.readouts[index]
    }

    private func note(readout: PerformanceReadout) -> String {
        var parts = ["median"]

        if let change = readout.change {
            parts.append(Self.percent(change: change))
        }

        if let version = release.performance.previous?.version {
            parts.append("vs \(version)")
        }

        return parts.joined(separator: " · ")
    }
}

extension [Int] {
    fileprivate var recentFourteen: [Int] {
        let length = 14

        guard count > length else {
            return self
        }

        let last = lastIndex { $0 > 0 } ?? length - 1
        let start = Swift.max(0, Swift.min(last - length + 1, count - length))
        return Array(self[start..<Swift.min(start + length, count)])
    }
}

extension String {
    fileprivate var lowercasedAbbreviation: String {
        self == uppercased() ? self : lowercased()
    }
}
