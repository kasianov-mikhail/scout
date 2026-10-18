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
@Suite("MetricKitResource.log")
struct MetricKitResourceLogTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let start = Date(timeIntervalSince1970: 1_750_000_000)

    @Test("A resource exception saves its kind and amount")
    func savesKindAndAmount() throws {
        try makeResource(processID: nil).log(installID: Identity.stub.install, context: context)

        let entry = try #require(try context.fetchAll(ResourceEntry.self).first)
        #expect(entry.kind == "cpu")
        #expect(entry.value == 92)
        #expect(entry.name == "CPU Exception")
        #expect(entry.source == "metrickit")
    }

    @Test("A resource exception links to the last session of its process")
    func linksToSession() throws {
        let launch = LaunchEntry.stub(date: start, install: InstallEntry.stub(date: start, in: context), in: context)
        launch.processID = 412
        let session = SessionEntry.stub(date: start.addingTimeInterval(300), launch: launch, in: context)
        session.sessionID = UUID()

        try makeResource(processID: 412).log(installID: Identity.stub.install, context: context)

        let entry = try #require(try context.fetchAll(ResourceEntry.self).first)
        #expect(entry.session == session)
    }

    @Test("A redelivered exception adds no row")
    func redeliveryIsIgnored() throws {
        let resource = makeResource(processID: nil)

        try resource.log(installID: Identity.stub.install, context: context)
        try resource.log(installID: Identity.stub.install, context: context)

        #expect(try context.fetchAll(ResourceEntry.self).count == 1)
    }

    private func makeResource(processID: Int32?) -> MetricKitResource {
        MetricKitResource(
            kind: .cpu,
            amount: 92,
            sampledSeconds: 180,
            appVersion: "3.2.0",
            processID: processID,
            window: DateInterval(start: start.addingTimeInterval(60), end: start.addingTimeInterval(1_800)),
            frames: [MetricKitStackTree.Frame(binaryName: "MyApp", binaryUUID: nil, offsetIntoBinaryTextSegment: 4096, address: nil, sampleCount: 9, subFrames: [])]
        )
    }
}
