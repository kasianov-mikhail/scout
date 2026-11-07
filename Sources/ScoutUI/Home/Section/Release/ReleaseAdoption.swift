//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ReleaseAdoption {
    struct Version: Identifiable {
        let id: String
        let share: Double
        let stability: Stability
        let shipped: Date?

        var shareLabel: String {
            "\(Int((share * 100).rounded()))%"
        }

        var showsLabel: Bool {
            share >= 0.15
        }

        var shippedLabel: String {
            guard let shipped else {
                return ""
            }
            return " · shipped \(DateFormatter.monthDay.string(from: shipped))"
        }
    }

    let versions: [Version]

    var top: Version? {
        versions.first
    }

    var headline: String {
        guard let top else {
            return "—"
        }
        return "\(top.shareLabel) on \(top.id)"
    }
}

extension ReleaseAdoption {
    static let sample: ReleaseAdoption = {
        let end = Date().startOfDay

        return ReleaseAdoption(versions: [
            Version(id: "3.2.0", share: 0.62, stability: Stability(0.9982), shipped: end.addingDay(-14)),
            Version(id: "3.1.4", share: 0.21, stability: Stability(0.9967), shipped: end.addingDay(-27)),
            Version(id: "3.1.0", share: 0.10, stability: Stability(0.9921), shipped: end.addingDay(-42)),
            Version(id: "3.0.2", share: 0.05, stability: Stability(0.9890), shipped: end.addingDay(-58)),
            Version(id: "2.9.9", share: 0.02, stability: Stability(0.9710), shipped: end.addingDay(-75)),
        ])
    }()
}
