//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct IncidentSummary {
    let kind: IncidentKind
    let message: String
    let meta: String
    let cards: [IncidentSummaryCard]
    let affected: [IncidentAffected]
    let frames: [IncidentStackFrame]
    let stackCaption: String

    init<Element: Incident>(kind: IncidentKind, label: String, message: String?, group: IncidentGroup<Element>, breakdown: IncidentBreakdown?, cards: [IncidentSummaryCard], stack: [String]) {
        self.kind = kind
        self.message = message ?? group.name
        self.meta = Self.metaText(label: label, version: Self.firstVersion(group: group, breakdown: breakdown), lastDate: group.lastDate)
        self.cards = cards
        self.affected = breakdown?.affected ?? []
        self.frames = IncidentStackFrame.frames(from: stack)
        self.stackCaption = kind.stackCaption
    }
}

extension IncidentSummary {
    private static func firstVersion<Element: Incident>(group: IncidentGroup<Element>, breakdown: IncidentBreakdown?) -> String? {
        guard group.hasAllRecords else {
            return nil
        }
        guard let firstDate = group.firstDate else {
            return nil
        }
        guard let earliest = group.records.min(by: { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }) else {
            return nil
        }
        guard let date = earliest.date, date < firstDate.addingTimeInterval(.hour) else {
            return nil
        }
        guard let sessionID = earliest.sessionID else {
            return nil
        }
        return breakdown?.appVersionsBySession[sessionID]
    }

    private static func metaText(label: String, version: String?, lastDate: Date?) -> String {
        var parts = [label]
        if let version {
            parts.append("since \(version)")
        }
        if let lastDate {
            parts.append("last seen \(lastDate.relativeString)")
        }
        return parts.joined(separator: " · ")
    }
}

struct IncidentAffected: Identifiable {
    static let titles = ["Devices", "OS versions", "App versions"]

    let title: String
    let segments: [Segment]
    var usesDeviceNames = false

    var id: String {
        title
    }

    var total: Int {
        segments.total
    }
}
