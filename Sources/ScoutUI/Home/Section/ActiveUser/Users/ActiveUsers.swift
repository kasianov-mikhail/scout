//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ActiveUsers {
    let metrics: [ActiveUsersMetric]
    let start: Date
    let end: Date
    let monthlyUsers: Int
    let medianSession: TimeInterval?
    let newDevicesToday: Bool
    let devicesThisWeek: Int
}

extension ActiveUsers {
    func metric(_ kind: Kind) -> ActiveUsersMetric? {
        metrics.first { $0.kind == kind }
    }

    var stickiness: Double {
        guard let dau = metric(.dau), monthlyUsers > 0 else {
            return 0
        }
        return Double(dau.value) / Double(monthlyUsers)
    }

    var sessionsPerUser: Double {
        guard let dau = metric(.dau), let sessions = metric(.sessions), dau.value > 0 else {
            return 0
        }
        return Double(sessions.value) / Double(dau.value)
    }

    var stickinessLabel: String {
        String(format: "%.1f%%", stickiness * 100)
    }

    var sessionsPerUserLabel: String {
        String(format: "%.1f", sessionsPerUser)
    }

    var medianSessionLabel: String? {
        guard let medianSession else {
            return nil
        }
        let seconds = Int(medianSession)
        return "\(seconds / 60) min \(seconds % 60) s"
    }

    var devicesThisWeekLabel: String {
        devicesThisWeek.formatted(.number.locale(Locale(identifier: "en_US")))
    }
}
