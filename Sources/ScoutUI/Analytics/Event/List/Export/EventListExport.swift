//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct EventListExport {
    let events: [Event]
    var isTruncated = false

    var text: String? {
        guard !events.isEmpty else { return nil }

        var lines: [ExportLine] = [.heading(level: 1, title), .text(summary), .blank]
        lines.append(contentsOf: events.map(row))

        return lines.text
    }
}

extension EventListExport {
    private var title: String {
        "Scout Events"
    }

    private var summary: String {
        let counted = ExportFormat.counted(events.count, .event)
        return isTruncated ? "\(counted) loaded · more available" : counted
    }

    private func row(for event: Event) -> ExportLine {
        var parts: [String] = []
        if let date = event.date {
            parts.append(ExportFormat.timestamp(date))
        }
        parts.append(event.name)
        if let level = event.level {
            parts.append("[\(level.rawValue)]")
        }
        return .bullet(parts.joined(separator: "  "))
    }
}
