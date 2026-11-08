//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DevicesExport {
    let models: [DeviceModelSummary]

    var text: String? {
        guard !models.isEmpty else { return nil }
        var lines: [ExportLine] = [.heading(level: 1, title), .text(summary), .blank]
        lines.append(contentsOf: models.map(row))
        return lines.text
    }
}

extension DevicesExport {
    private var title: String {
        "Scout Devices"
    }

    private var summary: String {
        let count = models.count
        let devices = models.map(\.devices).reduce(0, +)
        return "\(count) \(count == 1 ? "model" : "models") · \(ExportFormat.counted(devices, .device))"
    }

    private func row(for model: DeviceModelSummary) -> ExportLine {
        let devices = ExportFormat.counted(model.devices, .device)
        let sessions = ExportFormat.counted(model.sessions, .session)
        let crashes = ExportFormat.counted(model.crashes, .crash)
        return .bullet("\(model.name)  (\(devices), \(sessions), \(model.osLabel ?? "—"), \(crashes))")
    }
}
