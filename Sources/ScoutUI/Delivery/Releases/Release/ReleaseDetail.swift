//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct ReleaseDetail {
    let release: ReleaseHealth
    let trend: VersionTrend
    let now: Date

    var age: Int {
        guard let shipped = release.shipped else {
            return 0
        }
        return Calendar.utc.dateComponents([.day], from: shipped.startOfDay, to: now.startOfDay).day ?? 0
    }

    var statusLabel: String {
        "\(release.freeSessions.level.displayTitle) · \(release.freeSessions.formatted) crash-free"
    }

    var subtitle: String {
        let share = "\(release.adoption.formatted) of sessions"
        guard release.shipped != nil else {
            return share
        }
        return "\(share) · day \(max(age, 0))"
    }

    var tiles: [ReleaseTileValue] {
        [
            ReleaseTileValue(
                kind: .crashFree,
                value: release.freeSessions.formatted,
                color: .primary,
                chart: .zones(release.freeSessions.value),
                footer: release.freeUsers.map { "users \($0.formatted)" }
            ),
            ReleaseTileValue(
                kind: .adoption,
                value: release.adoption.formatted,
                color: .primary,
                chart: .progress(release.adoption.value),
                footer: "\(release.sessions.compact) sessions"
            ),
            ReleaseTileValue(
                kind: .crashes,
                value: "\(release.crashes)",
                color: .crashText,
                chart: .bars(trend.crashes.map(\.count), .fillDanger),
                footer: "\(trend.crashes.today) today"
            ),
            ReleaseTileValue(
                kind: .hangs,
                value: "\(release.hangs)",
                color: .hangText,
                chart: .bars(trend.hangs.map(\.count), .fillWarning),
                footer: "\(trend.hangs.today) today"
            ),
            ReleaseTileValue(
                kind: .resources,
                value: "\(release.resources.total)",
                color: .resourceText,
                chart: .bars(trend.resources.map(\.count), .fillResource),
                footer: resourceFooter
            ),
            ReleaseTileValue(
                kind: .exits,
                value: abnormalLabel,
                color: .primary,
                chart: .segments(release.exits.abnormal.prefix(4).map { Double($0.count) }),
                footer: release.exits.abnormal.first.map { "\($0.reason.title.lowercased()) \($0.formatted)" }
            ),
            ReleaseTileValue(
                kind: .launchTime,
                value: launchLabel,
                color: .primary,
                chart: .bars(Array(release.performance.current.launchHistogram.counts.prefix(14)), nil),
                footer: footer(title: "median", change: release.performance.change(\.launchTime))
            ),
            ReleaseTileValue(
                kind: .peakMemory,
                value: memoryLabel,
                color: .primary,
                chart: .bars(Array(release.performance.current.memoryHistogram.counts.prefix(14)), nil),
                footer: footer(title: "median", change: release.performance.change(\.peakMemory))
            ),
        ]
    }

    var hangRate: ReleaseHangRate {
        let value = release.performance.current.hangRate.map { String(format: "%.1f s/h", $0) } ?? "—"
        guard let change = release.performance.change(\.hangRate) else {
            return ReleaseHangRate(value: value, change: nil, color: Color.fillLevel)
        }
        return ReleaseHangRate(value: value, change: percentLabel(change), color: change > 0 ? Color.textWarning : Stability.Level.healthy.labelColor)
    }
}

extension ReleaseDetail {
    private var launchLabel: String {
        release.performance.current.launchTime.map { String(format: "%.0f ms", $0) } ?? "—"
    }

    private var memoryLabel: String {
        release.performance.current.peakMemory.map { String(format: "%.0f MB", $0) } ?? "—"
    }

    private var abnormalLabel: String {
        String(format: "%.1f ‰", abnormalPerMille)
    }

    private var abnormalPerMille: Double {
        guard release.exits.total > 0 else {
            return 0
        }
        let abnormal = release.exits.abnormal.map(\.count).reduce(0, +)
        return Double(abnormal) * 1_000 / Double(release.exits.total)
    }

    private var resourceFooter: String {
        let parts = [ResourceKind.cpu, .diskWrite].compactMap { kind -> String? in
            guard let count = release.resources.counts[kind], count > 0 else {
                return nil
            }
            return "\(kind == .cpu ? "CPU" : "disk") \(count)"
        }
        let today = "\(trend.resources.today) today"

        return parts.isEmpty ? today : today + " · " + parts.joined(separator: ", ")
    }

    private func footer(title: String, change: Double?) -> String {
        guard let change, let version = release.performance.previous?.version else {
            return title
        }
        return "\(title) · \(percentLabel(change)) vs \(version)"
    }

    private func percentLabel(_ change: Double) -> String {
        let percent = (change * 100).rounded()

        guard percent != 0 else {
            return "±0%"
        }
        return percent > 0 ? "+\(Int(percent))%" : "−\(abs(Int(percent)))%"
    }
}
