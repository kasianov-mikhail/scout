//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

@Suite("NetworkReportExport")
struct NetworkReportExportTests {
    let base = Date(year: 2026, month: 6, day: 1)

    var range: Range<Date> {
        base..<base.adding(.day)
    }

    @Test("A report with endpoints renders its summary, status codes, and endpoint rows")
    func testReportExport() throws {
        let report = NetworkReport(series: [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 99)]),
            makeSeries(name: "GET /a", category: "status_5xx", points: [(base, 1)]),
            makeSeries(name: "GET /a", category: "timer_le_1", points: [(base, 100)]),
        ])
        let text = try #require(NetworkReportExport(report: report, range: range).text)

        #expect(text.hasPrefix("# Scout Network Report"))
        #expect(text.contains("100 requests"))
        #expect(text.contains("## Status codes"))
        #expect(text.contains("- 2xx: 99 requests"))
        #expect(text.contains("- 5xx: 1 request"))
        #expect(text.contains("## Endpoints"))
        #expect(text.contains("- GET /a  (100 requests, success"))
    }

    @Test("A report with no endpoints in range exports nothing")
    func testEmptyReportExport() {
        let report = NetworkReport(series: [])
        #expect(NetworkReportExport(report: report, range: range).text == nil)
    }

    private func makeSeries(name: String, category: String, points: [(Date, Int)]) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: points.map { date, count in
                MetricSeriesPoint(date: date.millisecondsSince1970, value: .int(count))
            }
        )
    }
}
