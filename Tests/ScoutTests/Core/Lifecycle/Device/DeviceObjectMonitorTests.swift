//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("DeviceObject+Monitor")
struct DeviceObjectMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub

    @Test("trigger stamps the device with its hardware model")
    func triggerStampsModel() throws {
        try DeviceObject.Trigger(deviceID: identity.device).execute(in: context)

        let device = try #require(try context.fetchAll(DeviceObject.self).first)
        #expect(device.model == SystemInfo.deviceModel)
        #expect(device.model?.isEmpty == false)
    }

    @Test("trigger inserts a single device for the current deviceID")
    func triggerIsIdempotent() throws {
        try DeviceObject.Trigger(deviceID: identity.device).execute(in: context)
        try DeviceObject.Trigger(deviceID: identity.device).execute(in: context)

        #expect(try context.fetchAll(DeviceObject.self).count == 1)
    }
}
