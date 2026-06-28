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
    let group: CrashGroup

    var text: String {
        var lines = [title, summary]

        if let seen = seenLine {
            lines.append(seen)
        }
        if let reason = group.representative.reason {
            lines.append("")
            lines.append("Reason: \(reason)")
        }
        if let frame = topFrame {
            lines.append("")
            lines.append("Top frame: \(frame)")
        }

        let rows = group.crashes.compactMap(row)
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

    private var summary: String {
        var parts = [ExportFormat.counted(group.count, "occurrence", "occurrences")]
        if group.affectedDevices > 0 {
            parts.append(ExportFormat.counted(group.affectedDevices, "device", "devices"))
        }
        if group.affectedSessions > 0 {
            parts.append(ExportFormat.counted(group.affectedSessions, "session", "sessions"))
        }
        return parts.joined(separator: " · ")
    }

    private var seenLine: String? {
        guard let first = group.firstDate, let last = group.lastDate else {
            return nil
        }
        return "First seen \(ExportFormat.minute(first)) · Last seen \(ExportFormat.minute(last))"
    }

    private var topFrame: String? {
        group.representative.stackTrace.first { !$0.isEmpty }
    }

    private func row(for crash: Crash) -> String? {
        guard let date = crash.date else {
            return nil
        }

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
