//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct EventListExport {
    let events: [Event]

    var text: String? {
        guard events.count > 0 else { return nil }

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
        ExportFormat.counted(events.count, .event)
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
