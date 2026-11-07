//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct TimelineRowsBuilder {
    static let rowHeight: CGFloat = 44
    static let compactHeight: CGFloat = 36

    private static let gapThreshold: TimeInterval = 10 * 60

    private let rail: Rail

    let incidents: TimelineIncidents
    let focus: TimelineFocus?
    let now: Date
    let reachesStart: Bool
    let reachesEnd: Bool

    let crashesBySession: [UUID: [Crash]]
    let hangsBySession: [UUID: [Hang]]
    let resourcesBySession: [UUID: [ResourceException]]
    let versionByLaunch: [UUID: String]
    let launchBounds: [Date: Date]
    let loadedRange: ClosedRange<Date>?
    let lastLaunchID: UUID?

    var entries: [TimelineEntry] = []
    var previousEnd: Date?
    var previousVersion: String?
    var previousLaunchDay: Date?

    init(rail: Rail, incidents: TimelineIncidents, focus: TimelineFocus?, now: Date, reachesStart: Bool, reachesEnd: Bool) {
        self.rail = rail
        self.incidents = incidents
        self.focus = focus
        self.now = now
        self.reachesStart = reachesStart
        self.reachesEnd = reachesEnd
        self.crashesBySession = Self.group(incidents.crashes, by: \.sessionID)
        self.hangsBySession = Self.group(incidents.hangs, by: \.sessionID)
        self.resourcesBySession = Self.group(incidents.resources, by: \.sessionID)
        self.versionByLaunch = Self.versions(incidents.versions)
        self.launchBounds = Self.bounds(for: rail.installs.flatMap(\.launches).compactMap(\.launch.startDate))
        self.loadedRange = Self.range(for: rail.installs.flatMap(\.launches).flatMap(\.sessions).compactMap(\.session.startDate))
        self.lastLaunchID = rail.installs.last?.launches.last?.launch.launchID
    }

    mutating func build() -> [TimelineEntry] {
        for (index, install) in rail.installs.enumerated() {
            appendInstall(install, isFirst: index == 0)
        }
        var seen: Set<String> = []
        entries = entries.filter { seen.insert($0.id).inserted }
        markSeparators()
        return entries
    }
}

extension TimelineRowsBuilder {
    mutating func appendGap(from start: Date, to end: Date) {
        let interval = end.timeIntervalSince(start)
        guard interval >= Self.gapThreshold else {
            return
        }

        entries.append(
            TimelineEntry(
                id: "gap-\(Int(end.timeIntervalSince1970))",
                kind: .gap,
                height: Self.compactHeight,
                launch: TimelineEntry.Lane(color: .timelinePending, dashed: true, top: 0, bottom: 0),
                session: nil,
                connector: nil,
                marker: nil,
                title: label(interval.timelineGap, size: 13, weight: .regular, color: .timelineMuted, italic: true),
                subtitle: nil,
                time: nil,
                chip: nil,
                tint: nil
            )
        )
    }

    func label(_ text: String, size: CGFloat, weight: Font.Weight, color: Color, italic: Bool = false, monospaced: Bool = false) -> TimelineEntry.Label {
        TimelineEntry.Label(text: text, size: size, weight: weight, color: color, italic: italic, monospaced: monospaced)
    }
}

extension TimelineRowsBuilder {
    private mutating func markSeparators() {
        for index in entries.indices where entries[index].kind.isItem {
            guard index + 1 < entries.count else {
                continue
            }
            entries[index].showsSeparator = entries[index + 1].kind.isItem
        }
    }
}

extension TimelineRowsBuilder {
    private static func group<Element>(_ elements: [Element], by keyPath: KeyPath<Element, UUID?>) -> [UUID: [Element]] {
        var result: [UUID: [Element]] = [:]
        for element in elements {
            guard let id = element[keyPath: keyPath] else {
                continue
            }
            result[id, default: []].append(element)
        }
        return result
    }

    private static func bounds(for starts: [Date]) -> [Date: Date] {
        var result: [Date: Date] = [:]
        var next: Date?
        for start in Set(starts).sorted(by: >) {
            if let next {
                result[start] = next
            }
            next = start
        }
        return result
    }

    private static func range(for starts: [Date]) -> ClosedRange<Date>? {
        guard let lower = starts.min(), let upper = starts.max() else {
            return nil
        }
        return lower...upper
    }

    private static func versions(_ versions: [Version]) -> [UUID: String] {
        var result: [UUID: String] = [:]
        for version in versions.sorted(byDate: \.date) {
            guard let launchID = version.launchID, let appVersion = version.appVersion else {
                continue
            }
            result[launchID] = appVersion
        }
        return result
    }
}

private let timelineTimeFormatter = DateFormatter(format: "HH:mm")
private let timelineSecondFormatter = DateFormatter(format: "HH:mm:ss")
private let timelineDayFormatter = DateFormatter(format: "MMM d")

extension Date {
    var timelineTime: String {
        timelineTimeFormatter.string(from: self)
    }

    var timelineSecond: String {
        timelineSecondFormatter.string(from: self)
    }

    var timelineDay: String {
        timelineDayFormatter.string(from: self)
    }
}

extension TimeInterval {
    var timelineDuration: String {
        let total = Int(max(self, 0).rounded())
        let hours = total / 3_600
        let minutes = total % 3_600 / 60
        let seconds = total % 60

        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        if minutes > 0 {
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes)m"
        }
        return "\(seconds)s"
    }

    var timelineGap: String {
        let seconds = max(self, 0)

        if seconds < 3_600 {
            return "\(max(Int((seconds / 60).rounded()), 1)) m"
        }
        if seconds < 86_400 {
            return "\(Int((seconds / 3_600).rounded())) h"
        }
        let days = Int((seconds / 86_400).rounded())
        return days == 1 ? "1 day" : "\(days) days"
    }
}
