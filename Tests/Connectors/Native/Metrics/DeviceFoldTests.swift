//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import Testing

@testable import NativeConnector
@testable import Scout

@Suite("Device fold")
struct DeviceFoldTests {
    private let start = Date(timeIntervalSince1970: 1_750_000_000)

    @Test("Sums the sessions of each device and takes the system of its latest hour")
    func foldsPerDevice() {
        let later = start.addingTimeInterval(3600)

        let fold = DeviceFold(
            sessions: [
                SeriesPoint(group: "a", date: start, value: 2),
                SeriesPoint(group: "a", date: later, value: 1),
                SeriesPoint(group: "b", date: start, value: 1),
            ],
            systems: [
                SeriesPoint(group: "a|iOS 17.3", date: start, value: 2),
                SeriesPoint(group: "a|iOS 17.4", date: later, value: 1),
                SeriesPoint(group: "", date: start, value: 1),
            ],
            crashes: ["a", "a"],
            models: ["a": "iPhone15,3"]
        )

        #expect(
            fold.activities == [
                DeviceActivity(deviceID: "a", model: "iPhone15,3", osVersion: "iOS 17.4", lastSeen: later, sessions: 3, crashes: 2),
                DeviceActivity(deviceID: "b", model: nil, osVersion: nil, lastSeen: start, sessions: 1, crashes: 0),
            ]
        )
    }

    @Test("A device seen only in crashes or models is left out")
    func sessionlessDevicesAreLeftOut() {
        let fold = DeviceFold(sessions: [], systems: [], crashes: ["a"], models: ["a": "iPhone15,3"])

        #expect(fold.activities.isEmpty)
    }
}
