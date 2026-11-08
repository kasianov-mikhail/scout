//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum MetricQuantile: String, CaseIterable, Identifiable {
    case p50
    case p90
    case p99

    var id: Self { self }
}

extension MetricQuantile {
    var title: String {
        rawValue.uppercased()
    }

    var value: Double {
        switch self {
        case .p50:
            0.5
        case .p90:
            0.9
        case .p99:
            0.99
        }
    }
}

extension Percentiles {
    func value(_ quantile: MetricQuantile) -> Double {
        switch quantile {
        case .p50:
            p50
        case .p90:
            p90
        case .p99:
            p99
        }
    }
}
