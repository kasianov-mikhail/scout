//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct IncidentExport<Element: Incident> {
    let incident: Element
    let kind: String
    let detail: [ExportLine]

    var text: String {
        var lines: [ExportLine] = [.heading(level: 1, "Scout \(kind) — \(incident.name)")]

        if let date = incident.date {
            lines.append(.text(ExportFormat.timestamp(date)))
        }
        lines.append(contentsOf: detail)
        if let reason = incident.reason {
            lines.append(.blank)
            lines.append(.text("Reason: \(reason)"))
        }
        if incident.stackTrace.count > 0 {
            lines.append(.blank)
            lines.append(.heading(level: 2, "Stack Trace"))
            lines.append(.code(incident.stackTrace))
        }

        return lines.text
    }
}

struct IncidentGroupExport<Element: Incident> {
    let group: IncidentGroup<Element>
    let kind: String
    let summaryDetail: [ExportLine]
    let rowSuffix: (Element) -> String

    var text: String {
        var lines: [ExportLine] = [
            .heading(level: 1, "Scout \(kind) Issue — \(group.name)"), .text(group.exportSummary),
        ]

        if let seen = group.exportSeenLine {
            lines.append(.text(seen))
        }
        lines.append(contentsOf: summaryDetail)
        if let frame = group.exportTopFrame {
            lines.append(.blank)
            lines.append(.text("Top frame: \(frame)"))
        }

        let rows = group.records.compactMap(row)
        if rows.count > 0 {
            lines.append(.blank)
            lines.append(.heading(level: 2, "Occurrences"))
            lines.append(contentsOf: rows)
        }

        return lines.text
    }

    private func row(for element: Element) -> ExportLine? {
        guard let date = element.date else { return nil }

        var ids: [String] = []
        if let deviceID = element.deviceID {
            ids.append("device \(ExportFormat.shortID(deviceID))")
        }
        if let sessionID = element.sessionID {
            ids.append("session \(ExportFormat.shortID(sessionID))")
        }

        let row = "\(ExportFormat.timestamp(date))\(rowSuffix(element))"
        return .bullet(ids.count > 0 ? "\(row)  (\(ids.joined(separator: ", ")))" : row)
    }
}
