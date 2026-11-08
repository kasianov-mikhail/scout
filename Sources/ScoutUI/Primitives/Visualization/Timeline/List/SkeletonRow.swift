//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SkeletonRow {
    enum Track {
        case milestone
        case event
        case fork
        case merge
        case gap
    }

    let track: Track
    let width: CGFloat
    let extraWidth: CGFloat?
}

extension SkeletonRow {
    static let samples: [SkeletonRow] = {
        var rows: [SkeletonRow] = [
            SkeletonRow(track: .milestone, width: 120, extraWidth: 74),
            SkeletonRow(track: .fork, width: 46, extraWidth: nil),
        ]

        let first = [106, 77, 134, 58, 106, 77, 134, 58, 106, 77]
        rows += first.map { SkeletonRow(track: .event, width: CGFloat($0), extraWidth: nil) }
        rows += [
            SkeletonRow(track: .merge, width: 74, extraWidth: nil),
            SkeletonRow(track: .gap, width: 28, extraWidth: nil),
            SkeletonRow(track: .milestone, width: 120, extraWidth: 74),
            SkeletonRow(track: .fork, width: 46, extraWidth: nil),
        ]

        let second = [106, 77, 134, 58, 106, 77, 134, 58, 106, 77, 134, 58, 106]
        rows += second.map { SkeletonRow(track: .event, width: CGFloat($0), extraWidth: nil) }
        return rows
    }()
}

extension SkeletonRow.Track {
    var isCompact: Bool {
        switch self {
        case .merge, .gap:
            true
        default:
            false
        }
    }
}
