//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct RetentionSegmentValue: Identifiable {
    let segment: RetentionSegment
    let rate: Double?
    let kept: Int?
    let pending: String?

    var id: String { segment.id }

    var name: String { segment.name }

    var installsLabel: String {
        "\(segment.size.formatted(.count)) \(segment.size == 1 ? "install" : "installs")"
    }

    var crashRateLabel: String {
        guard segment.size > 0 else {
            return "—"
        }
        return (Double(segment.crashes) / Double(segment.size)).formatted(.incidentRate)
    }

    var keptLabel: String? {
        kept.map { $0.formatted(.count) }
    }

    var rateLabel: String? {
        rate.map { $0.formatted(.retentionRate) }
    }

    var pendingLabel: String? {
        guard rate == nil else {
            return nil
        }
        return pending
    }
}
