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
        return [deviceSystem: .string(SystemScopedKey(value: device, system: system).key)]
    }
}
