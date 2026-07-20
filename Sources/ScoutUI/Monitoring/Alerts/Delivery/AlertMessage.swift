//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertMessage: Equatable {
    let title: String
    let body: String
}

extension AlertMessage {
    init?(status: AlertStatus) {
        guard status.outcome.shouldNotify, status.rule.notifies, let detail = status.detail else { return nil }

        title = status.rule.metric.title
        body = detail
    }
}

extension AlertMetric {
    var title: String {
        switch self {
        case .eventCount(let name):
            name
        case .crashFreeSessions:
            "Crash-free sessions"
        }
    }

    func format(_ value: Double) -> String {
        switch self {
        case .eventCount:
            String(Int(value))
        case .crashFreeSessions:
            Stability(value).formatted
        }
    }
}

extension AlertCondition {
    func summary(format: (Double) -> String) -> String {
        "\(comparison.summary) \(reference.summary(format: format))"
    }
}

extension AlertCondition.Comparison {
    fileprivate var summary: String {
        switch self {
        case .below:
            "below"
        case .above:
            "above"
        }
    }
}

extension AlertCondition.Reference {
    fileprivate func summary(format: (Double) -> String) -> String {
        switch self {
        case .constant(let value):
            format(value)
        case .baselineFactor(let factor):
            "\(factor.formattedFactor) baseline"
        case .medianFactor(let factor):
            "\(factor.formattedFactor) median"
        }
    }
}

extension Double {
    fileprivate var formattedFactor: String {
        String(format: "%g×", self)
    }
}
