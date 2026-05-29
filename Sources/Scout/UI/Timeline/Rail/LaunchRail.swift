//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct LaunchRail: Identifiable {
    let launch: Launch
    let sessions: [SessionRail]

    var id: CKRecord.ID { launch.id }
}

extension LaunchRail {
    static var sample: LaunchRail {
        LaunchRail(launch: .sample(at: Date().addingTimeInterval(-400)), sessions: [.sample, .crashed])
    }
}
