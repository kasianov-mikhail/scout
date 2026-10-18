//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("Condition")
struct ConditionTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub
    let date = TestDate.reference

    @Test("Thermal states map to their conditions")
    func thermalStates() {
        let states: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]

        #expect(states.map(Condition.init) == [.thermalNominal, .thermalFair, .thermalSerious, .thermalCritical])
    }

    @Test("The low power mode maps to its condition")
    func lowPowerMode() {
        #expect(Condition(lowPowerMode: true) == .lowPowerOn)
        #expect(Condition(lowPowerMode: false) == .lowPowerOff)
    }

    @Test("Trigger stores the condition in the current session")
    func triggerStores() throws {
        try ConditionEntry.Trigger(condition: .memoryWarning, value: 1024, identity: identity.snapshot, date: date).execute(in: context)

        let request = NSFetchRequest<ConditionEntry>(entityName: "ConditionEntry")
        let entry = try #require(try context.fetch(request).first)

        #expect(entry.kind == "memory_warning")
        #expect(entry.value == 1024)
        #expect(entry.date == date)
        #expect(entry.sessionID == identity.session.current)
    }
}
