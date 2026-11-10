//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI
import Testing

@testable import ScoutUI

@MainActor
@Suite("BackendReport")
struct BackendReportTests {
    @Test("A report with no data has no numbers for any section")
    func emptyReportHasNoNumbers() {
        let report = BackendReport()

        #expect(report.symbolsTitle == "Symbols")
        #expect(report.statusDetail == nil)
        #expect(report.database == nil)
        #expect(report.schema == nil)
        #expect(report.symbolsState == nil)
        #expect(report.latestEvent == nil)
        #expect(report.pendingRecords == nil)
        #expect(report.lastSent == nil)
        #expect(report.givenUp == nil)
        #expect(report.lastError == nil)
        #expect(report.storage == nil)
        #expect(report.storageCaption == nil)
        #expect(report.eventCount == nil)
        #expect(report.sessionCount == nil)
        #expect(report.metricCount == nil)
        #expect(report.errorRate == nil)
        #expect(report.requestCount == nil)
        #expect(report.serverErrors == nil)
        #expect(report.tooLarge == nil)
        #expect(report.badKey == nil)
        #expect(report.sendErrors == nil)
    }

    @Test("A backend detail screen without a report starts empty")
    func detailScreenStartsEmpty() {
        let view = BackendDetailView(
            provider: BackendHealthProvider(healths: [makeHealth(id: "backend")]),
            id: "backend",
            activeID: .constant("backend")
        )

        #expect(view.report.symbolsTitle == "Symbols")
        #expect(view.report.latestEvent == nil)
        #expect(view.report.pendingRecords == nil)
        #expect(view.report.storage == nil)
    }
}
