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
@Suite("DeviceObject")
struct DeviceObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = TestDate.reference.startOfWeek

    @Test("installs relationship holds the installs linked to the device")
    func testInstalls() throws {
        let device = DeviceObject.stub(date: week, in: context)

        InstallObject.stub(date: week, device: device, in: context)
        InstallObject.stub(date: week.addingHour(), device: device, in: context)
        InstallObject.stub(date: week, in: context)

        try context.save()

        #expect(device.installs.count == 2)
        #expect(device.installs.allSatisfy { $0.device == device })
    }
}
