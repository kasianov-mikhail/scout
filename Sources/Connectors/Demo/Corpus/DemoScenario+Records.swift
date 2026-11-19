//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DemoScenario {
    var records: [Record] {
        deviceRecords + installRecords + launchRecords + sessionRecords
    }

    private var deviceRecords: [Record] {
        installs.map { install in
            var record = Device(
                date: install.date,
                id: install.device.id.uuidString,
                deviceID: install.device.id
            )
            .record
            record["model"] = install.device.model
            return record
        }
    }

    private var installRecords: [Record] {
        installs.map { install in
            Install(
                date: install.date,
                id: install.id.uuidString,
                installID: install.id,
                deviceID: install.device.id
            )
            .record
        }
    }

    private var launchRecords: [Record] {
        sessions.map { session in
            var record = Launch(
                startDate: session.start,
                endDate: session.end,
                id: session.launchID.uuidString,
                launchID: session.launchID,
                installID: session.install.id
            )
            .record
            record["device_id"] = session.device.id.uuidString
            return record
        }
    }

    private var sessionRecords: [Record] {
        sessions.map { session in
            var record = session.versioned(
                Session(
                    startDate: session.start,
                    endDate: session.end,
                    id: session.id.uuidString,
                    sessionID: session.id,
                    launchID: session.launchID,
                    installID: session.install.id
                )
                .record
            )

            record["device_id"] = session.device.id.uuidString
            record["os_version"] = session.device.os
            record["build_number"] = session.version.build
            record["locale"] = session.install.locale
            record["channel"] = session.install.channel
            return record
        }
    }
}
