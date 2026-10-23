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
@Suite("IssueEntry")
struct IssueEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record ID joins the kind and the fingerprint")
    func recordID() {
        let record = makeIssue(status: "open", resolvedVersion: nil).record

        #expect(record.recordType == "Issue")
        #expect(record.recordID == "crash-fp")
    }

    @Test("The record decodes into an incident issue")
    func recordDecodes() throws {
        let issue = try IncidentIssue(record: makeIssue(status: "resolved", resolvedVersion: "2.4").record)

        #expect(issue.fingerprint == "fp")
        #expect(issue.kind == .crash)
        #expect(issue.status == .resolved)
        #expect(issue.resolvedVersion == "2.4")
        #expect(issue.date == date)
        #expect(issue.id == "crash-fp")
    }

    private func makeIssue(status: String, resolvedVersion: String?) -> IssueEntry {
        let object = context.insert(IssueEntry.self)
        object.fingerprint = "fp"
        object.kind = "crash"
        object.status = status
        object.resolvedVersion = resolvedVersion
        object.date = date
        return object
    }
}
