//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct DeviceRail: Identifiable {
    let device: Device
    let installs: [InstallRail]

    var id: CKRecord.ID {
        device.id
    }

    var pendingInstalls: [UUID] {
        installs
            .map(\.install)
            .sorted(byDate: \.date, ascending: false)
            .compactMap(\.installID)
    }
}

extension DeviceRail {
    static var sample: DeviceRail {
        DeviceRail(device: .sample(at: Date().addingTimeInterval(-600)), installs: [.sample])
    }
}
