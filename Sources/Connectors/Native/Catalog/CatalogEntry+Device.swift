//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension CatalogEntry {
    static let deviceSystem = "device_os"
    static let devicePageParts = 8

    static func deviceSystem(for record: Record) -> [String: ScoutDB.RecordValue] {
        let device: String? = record["device_id"]
        let system: String? = record["os_version"]

        guard let device else {
            return [:]
        }
        return [deviceSystem: .string(DeviceSystem(device: device, system: system).key)]
    }
}

struct DeviceSystem {
    let device: String
    let system: String?

    var key: String {
        [device, system ?? ""].joined(separator: "|")
    }
}

extension DeviceSystem {
    init?(key: String) {
        let parts = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)

        guard let device = parts.first else {
            return nil
        }
        guard !device.isEmpty else {
            return nil
        }

        self.init(device: String(device), system: parts.count > 1 && !parts[1].isEmpty ? String(parts[1]) : nil)
    }
}
