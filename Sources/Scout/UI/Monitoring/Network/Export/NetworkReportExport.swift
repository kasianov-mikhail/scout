//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct NetworkReportExport {
    let report: NetworkReport
    let range: Range<Date>

    var text: String? {
        let endpoints = report.endpoints(in: range)
        guard endpoints.count > 0 else { return nil }

        var lines: [ExportLine] = [
            .heading(level: 1, title), .text(summary), .blank, .heading(level: 2, "Status codes"),
        ]
        lines.append(contentsOf: statusLines)

        lines.append(.blank)
        lines.append(.heading(level: 2, "Endpoints"))
        lines.append(contentsOf: endpoints.map(row))

        return lines.text
    }
}

extension NetworkReportExport {
    private var title: String {
        "Scout Network Report"
    }

    private var summary: String {
        let breakdown = report.summary(in: range)

        var parts = [
            ExportFormat.range(from: range.lowerBound, to: range.upperBound),
            ExportFormat.counted(breakdown.total, .request),
        ]
        if breakdown.total > 0 {
            parts.append("success \(breakdown.successRate.formatted)")
        }
        if let p99 = report.percentiles(in: range)?.p99 {
            parts.append("p99 \(p99.duration)")
        }
        return parts.joined(separator: " · ")
    }

    private var statusLines: [ExportLine] {
        report.summary(in: range).segments.map { segment in
            .bullet("\(segment.label): \(ExportFormat.counted(segment.count, .request))")
        }
    }

    private func row(for endpoint: NetworkEndpoint) -> ExportLine {
        var parts = [ExportFormat.counted(endpoint.requests, .request)]
        if let successRate = endpoint.successRate {
            parts.append("success \(successRate.formatted)")
        }
        if let p99 = endpoint.p99 {
            parts.append("p99 \(p99.duration)")
        }
        return .bullet("\(endpoint.name)  (\(parts.joined(separator: ", ")))")
    }
}
