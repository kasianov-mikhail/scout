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

    @Test("installs(in:) returns installs whose device relationship matches")
    func testInstalls() throws {
        let device = DeviceObject.stub(date: week, in: context)

        let i1 = InstallObject.stub(date: week, in: context)
        i1.device = device

        let i2 = InstallObject.stub(date: week.addingHour(), in: context)
        i2.device = device

        InstallObject.stub(date: week, in: context).device = DeviceObject.stub(date: week, in: context)

        try context.save()

        let installs = try device.installs(in: context)
        #expect(installs.count == 2)
        #expect(installs.allSatisfy { $0.device === device })
    }
}
