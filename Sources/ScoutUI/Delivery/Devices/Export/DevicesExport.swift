//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

struct DevicesExport {
    let devices: [DeviceSummary]

    var text: String? {
        guard devices.count > 0 else {
            return nil
        }
        var lines: [ExportLine] = [.heading(level: 1, title), .text(summary), .blank]
        lines.append(contentsOf: devices.sorted { $0.lastSeen > $1.lastSeen }.map(row))
        return lines.text
    }
}

extension DevicesExport {
    private var title: String {
        "Scout Devices"
    }

    private var summary: String {
        ExportFormat.counted(devices.count, .device)
    }

    private func row(for device: DeviceSummary) -> ExportLine {
        let sessions = ExportFormat.counted(device.sessions, .session)
        let crashes = ExportFormat.counted(device.crashes, .crash)
        return .bullet(
            "\(device.modelName)  (\(device.osVersion), \(sessions), \(crashes), seen \(ExportFormat.timestamp(device.lastSeen)))"
        )
    }
}
