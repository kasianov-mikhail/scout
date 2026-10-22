//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

struct Rail {
    let device: Device
    var installs: [InstallRoot]
}

struct InstallRoot {
    let install: Install
    let launches: [LaunchRoot]
}

struct LaunchRoot {
    let launch: Launch
    let sessions: [SessionRoot]
}

struct SessionRoot {
    let session: Session
    let events: [Event]
    let crashes: [Crash]
}
