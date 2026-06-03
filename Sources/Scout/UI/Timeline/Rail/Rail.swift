//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Rail: Identifiable {
    let device: Device
    var installs: [InstallRoot]

    var id: CKRecord.ID { device.id }
}

struct InstallRoot: Identifiable {
    let install: Install
    let launches: [LaunchRoot]

    var id: CKRecord.ID { install.id }
}

struct LaunchRoot: Identifiable {
    let launch: Launch
    let sessions: [SessionRoot]

    var id: CKRecord.ID { launch.id }
}

struct SessionRoot: Identifiable {
    let session: Session
    let events: [Event]
    let crashes: [Crash]

    var id: CKRecord.ID { session.id }
}
