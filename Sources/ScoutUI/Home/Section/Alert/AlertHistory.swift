//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertHistory: Equatable {
    enum Bucket: Equatable {
        case clear
        case muted
        case firing
    }

    let buckets: [Bucket]
    let rule: String
    let firing: Int
    let armed: Int
    let muted: Int
    let total: Int
}

extension AlertHistory {
    var summary: String {
        "\(rule) · \(armed) armed · \(muted) muted"
    }

    var rulesLabel: String {
        "\(total) rule\(total == 1 ? "" : "s")"
    }
}

extension AlertHistory {
    static let sample = AlertHistory(
        buckets: [.clear, .clear]
            + Array(repeating: .muted, count: 5)
            + Array(repeating: .clear, count: 10)
            + Array(repeating: .firing, count: 7),
        rule: "Crash-free sessions",
        firing: 1,
        armed: 4,
        muted: 1,
        total: 6
    )
}
