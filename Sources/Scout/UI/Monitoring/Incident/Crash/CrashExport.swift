//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct CrashExport {
    let crash: Crash

    var text: String {
        var lines: [ExportLine] = [.heading(level: 1, "Scout Crash — \(crash.name)")]

        if let date = crash.date {
            lines.append(.text(ExportFormat.timestamp(date)))
        }
        if let reason = crash.reason {
            lines.append(.blank)
            lines.append(.text("Reason: \(reason)"))
        }
        if crash.stackTrace.count > 0 {
            lines.append(.blank)
            lines.append(.heading(level: 2, "Stack Trace"))
            lines.append(.code(crash.stackTrace))
        }

        return lines.text
    }
}

struct CrashGroupExport {
    let group: IncidentGroup<Crash>

    var text: String {
        var lines: [ExportLine] = [.heading(level: 1, title), .text(group.exportSummary)]

        if let seen = group.exportSeenLine {
            lines.append(.text(seen))
        }
        if let reason = group.representative.reason {
            lines.append(.blank)
            lines.append(.text("Reason: \(reason)"))
        }
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

    private var title: String {
        "Scout Crash Issue — \(group.name)"
    }

    private func row(for crash: Crash) -> ExportLine? {
        guard let date = crash.date else { return nil }

        var ids: [String] = []
        if let deviceID = crash.deviceID {
            ids.append("device \(ExportFormat.shortID(deviceID))")
        }
        if let sessionID = crash.sessionID {
            ids.append("session \(ExportFormat.shortID(sessionID))")
        }

        let row = ExportFormat.timestamp(date)
        return .bullet(ids.count > 0 ? "\(row)  (\(ids.joined(separator: ", ")))" : row)
    }
}
