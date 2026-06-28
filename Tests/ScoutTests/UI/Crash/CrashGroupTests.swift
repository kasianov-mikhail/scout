//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CrashGroupTests {
    @Test("Crashes sharing a fingerprint collapse into one group") func testGroupingByFingerprint() {
        let crashes = [
            Crash.stub(name: "A", fingerprint: "fp1"),
            Crash.stub(name: "A", fingerprint: "fp1"),
            Crash.stub(name: "B", fingerprint: "fp2"),
        ]

        let groups = CrashGroup.groups(from: crashes)

        #expect(groups.count == 2)
        #expect(groups.map(\.count).sorted() == [1, 2])
    }

    @Test("The representative is the most recent crash in the group") func testRepresentativeIsLatest() {
        let old = Crash.stub(fingerprint: "fp", date: Date(timeIntervalSince1970: 1000))
        let new = Crash.stub(fingerprint: "fp", date: Date(timeIntervalSince1970: 2000))

        let group = CrashGroup.groups(from: [old, new])[0]

        #expect(group.representative.id == new.id)
        #expect(group.firstDate == old.date)
        #expect(group.lastDate == new.date)
    }

    @Test("Groups are ordered by most recent occurrence first") func testGroupOrderByRecency() {
        let crashes = [
            Crash.stub(fingerprint: "old", date: Date(timeIntervalSince1970: 1000)),
            Crash.stub(fingerprint: "new", date: Date(timeIntervalSince1970: 2000)),
        ]

        let groups = CrashGroup.groups(from: crashes)

        #expect(groups.map(\.representative.fingerprint) == ["new", "old"])
    }

    @Test("Ties on recency are broken by occurrence count") func testTieBreakByCount() {
        let date = Date(timeIntervalSince1970: 1000)
        let crashes = [
            Crash.stub(fingerprint: "single", date: date),
            Crash.stub(fingerprint: "double", date: date),
            Crash.stub(fingerprint: "double", date: date),
        ]

        let groups = CrashGroup.groups(from: crashes)

        #expect(groups.map(\.representative.fingerprint) == ["double", "single"])
    }

    @Test("Affected sessions count distinct sessions") func testAffectedSessions() {
        let session = UUID()
        let crashes = [
            Crash.stub(fingerprint: "fp", sessionID: session),
            Crash.stub(fingerprint: "fp", sessionID: session),
            Crash.stub(fingerprint: "fp", sessionID: UUID()),
            Crash.stub(fingerprint: "fp", sessionID: nil),
        ]

        let group = CrashGroup.groups(from: crashes)[0]

        #expect(group.affectedSessions == 2)
    }
}
