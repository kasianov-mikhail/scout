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
        var lines = ["# Scout Crash — \(crash.name)"]

        if let date = crash.date {
            lines.append(ExportFormat.timestamp(date))
        }
        if let reason = crash.reason {
            lines.append("")
            lines.append("Reason: \(reason)")
        }
        if crash.stackTrace.count > 0 {
            lines.append("")
            lines.append("## Stack Trace")
            lines.append("```")
            lines.append(contentsOf: crash.stackTrace)
            lines.append("```")
        }

        return lines.joined(separator: "\n")
    }
}

struct CrashGroupExport {
    let group: IncidentGroup<Crash>

    var text: String {
        var lines = [title, group.exportSummary]

        if let seen = group.exportSeenLine {
            lines.append(seen)
        }
        if let reason = group.representative.reason {
            lines.append("")
            lines.append("Reason: \(reason)")
        }
        if let frame = group.exportTopFrame {
            lines.append("")
            lines.append("Top frame: \(frame)")
        }

        let rows = group.records.compactMap(row)
        if rows.count > 0 {
            lines.append("")
            lines.append("## Occurrences")
            lines.append(contentsOf: rows)
        }

        return lines.joined(separator: "\n")
    }

    private var title: String {
        "# Scout Crash Issue — \(group.name)"
    }

    private func row(for crash: Crash) -> String? {
        guard let date = crash.date else { return nil }

        var ids: [String] = []
        if let deviceID = crash.deviceID {
            ids.append("device \(ExportFormat.shortID(deviceID))")
        }
        if let sessionID = crash.sessionID {
            ids.append("session \(ExportFormat.shortID(sessionID))")
        }

        let row = "- \(ExportFormat.timestamp(date))"
        return ids.count > 0 ? "\(row)  (\(ids.joined(separator: ", ")))" : row
    }
}
