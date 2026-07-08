//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DevicesExport {
    let devices: [DeviceSummary]

    var text: String? {
        guard devices.count > 0 else { return nil }
        var lines = [title, summary, ""]
        lines.append(contentsOf: devices.sorted { $0.lastSeen > $1.lastSeen }.map(row))
        return lines.joined(separator: "\n")
    }
}

extension DevicesExport {
    private var title: String { "# Scout Devices" }
    private var summary: String { ExportFormat.counted(devices.count, "device", "devices") }
    private func row(for device: DeviceSummary) -> String {
        let sessions = ExportFormat.counted(device.sessions, "session", "sessions")
        let crashes = ExportFormat.counted(device.crashes, "crash", "crashes")
        return "- \(device.model)  (\(device.osVersion), \(sessions), \(crashes), seen \(ExportFormat.timestamp(device.lastSeen)))"
    }
}
