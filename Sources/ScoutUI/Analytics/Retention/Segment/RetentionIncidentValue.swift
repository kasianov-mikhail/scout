//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct RetentionIncidentValue {
    let kind: IncidentKind
    let count: Int
    let size: Int
    let weekRate: Double?

    var rateLabel: String {
        guard size > 0 else {
            return "—"
        }
        return (Double(count) / Double(size)).formatted(.incidentRate)
    }

    var countLabel: String {
        "\(count.formatted(.count)) \(count == 1 ? "install" : "installs")"
    }

    var title: String {
        switch kind {
        case .crash: "Crashed"
        case .hang: "Hung"
        case .resource: "Resource exception"
        }
    }

    var subtitle: String {
        guard let weekRate else {
            return title
        }
        return "\(title) · week \(weekRate.formatted(.incidentRate))"
    }

    var color: Color {
        switch kind {
        case .crash: .crashText
        case .hang: .hangText
        case .resource: .resourceText
        }
    }
}
