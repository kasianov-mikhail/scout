//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ActiveUsers {
    enum Kind: Hashable, Identifiable {
        case dau
        case sessions
        case devices

        var id: Self { self }

        var title: String {
            switch self {
            case .dau: "DAU"
            case .sessions: "SESSIONS"
            case .devices: "DEVICES"
            }
        }
    }

    struct Metric: Identifiable {
        let kind: Kind
        let value: Int
        let delta: Double
        let series: [Int]

        var id: Kind { kind }

        var valueLabel: String {
            value.formatted(.number.locale(Locale(identifier: "en_US")))
        }

        var deltaLabel: String {
            let percent = (delta * 1000).rounded() / 10
            let format = percent == percent.rounded() ? "%+.0f%%" : "%+.1f%%"

            return String(format: format, percent)
        }
    }

    let metrics: [Metric]
    let start: Date
    let end: Date
    let monthlyUsers: Int
}

extension ActiveUsers {
    func metric(_ kind: Kind) -> Metric? {
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
}

extension ActiveUsers {
    static let sample: ActiveUsers = {
        let end = Date().startOfDay

        return ActiveUsers(
            metrics: [
                Metric(
                    kind: .dau,
                    value: 1212,
                    delta: 0.041,
                    series: [
                        1083, 1119, 1138, 1101, 1065, 1119, 1156, 1083, 1138, 1156,
                        1119, 1083, 1138, 1174, 1119, 1138, 1174, 1156, 1101, 1156,
                        1174, 1138, 1192, 1282, 1228, 1101, 1246, 1300, 1174, 1212,
                    ]
                ),
                Metric(
                    kind: .sessions,
                    value: 8412,
                    delta: 0.123,
                    series: [
                        7200, 7440, 7560, 7320, 7080, 7440, 7680, 7200, 7560, 7680,
                        7440, 7200, 7560, 7800, 7440, 7560, 7800, 7680, 7320, 7680,
                        7800, 7560, 7920, 8520, 8160, 7320, 8280, 8640, 7800, 8412,
                    ]
                ),
                Metric(
                    kind: .devices,
                    value: 38,
                    delta: 0.12,
                    series: [
                        33, 34, 35, 34, 32, 34, 35, 33, 34, 35,
                        34, 33, 35, 36, 34, 35, 36, 35, 34, 35,
                        36, 35, 37, 39, 38, 34, 38, 39, 36, 38,
                    ]
                ),
            ],
            start: end.addingDay(-29),
            end: end,
            monthlyUsers: 14259
        )
    }()
}
