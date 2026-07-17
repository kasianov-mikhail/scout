//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DeviceVisit: Equatable {
    let deviceID: String
    let date: Date
}

struct DevicesReport {
    let summaries: [DeviceSummary]
    let visits: [DeviceVisit]
}

extension DevicesReport {
    init(devices: [Record], sessions: [Record], crashes: [Record]) {
        summaries = DeviceSummary.summaries(devices: devices, sessions: sessions, crashes: crashes)
        visits = sessions.compactMap { record in
            guard let deviceID: String = record["device_id"], let date: Date = record["start_date"] else {
                return nil
            }
            return DeviceVisit(deviceID: deviceID, date: date)
        }
    }
}

extension [DeviceVisit] {
    func devices(in range: Range<Date>) -> Int {
        reduce(into: Set<String>()) { devices, visit in
            if range.contains(visit.date) {
                devices.insert(visit.deviceID)
            }
        }
        .count
    }
}

extension DevicesReport {
    static var sample: DevicesReport {
        DevicesReport(
            summaries: .samples,
            visits: DeviceSummary.samples.enumerated().flatMap { index, device in
                (0..<6).map { day in
                    DeviceVisit(
                        deviceID: device.id.uuidString,
                        date: Date(timeIntervalSinceNow: -Double(day + index) * 86400)
                    )
                }
            }
        )
    }

    static let empty = DevicesReport(summaries: [], visits: [])
}
