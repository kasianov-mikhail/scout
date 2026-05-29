//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct InstallRail: Identifiable {
    let install: Install
    let launches: [LaunchRail]

    var id: CKRecord.ID { install.id }
}

extension InstallRail {
    static var sample: InstallRail {
        InstallRail(install: .sample(at: Date().addingTimeInterval(-500)), launches: [.sample])
    }
}
