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
    let week = Date(timeIntervalSince1970: 1_724_457_600).startOfWeek

    @Test("installs(in:) returns installs matching deviceID")
    func testInstalls() throws {
        let device = DeviceObject.stub(date: week, in: context)
        let deviceID = device.deviceID

        let i1 = InstallObject.stub(date: week, in: context)
        i1.deviceID = deviceID

        let i2 = InstallObject.stub(date: week.addingHour(), in: context)
        i2.deviceID = deviceID

        // Install with different deviceID
        InstallObject.stub(date: week, in: context).deviceID = UUID()

        try context.save()

        let installs = try device.installs(in: context)
        #expect(installs.count == 2)
        #expect(installs.allSatisfy { $0.deviceID == deviceID })
    }
}
