//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension DeviceRail {
    static var sample: DeviceRail {
        let now = Date()
        func at(_ offset: Int) -> Date { now.addingTimeInterval(TimeInterval(offset)) }

        return DeviceRail(
            device: .sample(at: at(-7100)),
            installs: [
                InstallRail(
                    install: .sample(at: at(-7100)),
                    launches: [
                        LaunchRail(
                            launch: .sample(at: at(-6900)),
                            sessions: [
                                SessionRail(
                                    session: .sample(at: at(-6600)),
                                    events: [
                                        .sample("setup", at: at(-6800)),
                                        .sample("schema_check", at: at(-6700)),
                                        .sample("ip_lookup", at: at(-6500)),
                                        .sample("ip_lookup", at: at(-6400)),
                                    ],
                                    crashes: []
                                ),
                                SessionRail(
                                    session: .sample(at: at(-6300)),
                                    events: [.sample("sync", at: at(-6200))],
                                    crashes: []
                                ),
                                SessionRail(
                                    session: .sample(at: at(-5400)),
                                    events: [.sample("ip_lookup", at: at(-5300))],
                                    crashes: [.sample("SIGABRT", at: at(-5200))]
                                ),
                            ]
                        ),
                        LaunchRail(
                            launch: .sample(at: at(-3500)),
                            sessions: [
                                SessionRail(
                                    session: .sample(at: at(-3300)),
                                    events: [
                                        .sample("setup", at: at(-3400)),
                                        .sample("ip_lookup", at: at(-3200)),
                                        .sample("search", at: at(-3000)),
                                    ],
                                    crashes: []
                                ),
                            ]
                        ),
                        LaunchRail(
                            launch: .sample(at: at(-300)),
                            sessions: [
                                SessionRail(
                                    session: .sample(at: at(-200)),
                                    events: [.sample("ip_lookup", at: at(-30))],
                                    crashes: []
                                ),
                            ]
                        ),
                    ]
                ),
            ]
        )
    }
}
