//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ReleaseVersion: Comparable {
    let version: String

    static func < (lhs: ReleaseVersion, rhs: ReleaseVersion) -> Bool {
        let lhsParts = lhs.version.split(separator: ".").map { Int($0) ?? 0 }
        let rhsParts = rhs.version.split(separator: ".").map { Int($0) ?? 0 }

        for index in 0..<max(lhsParts.count, rhsParts.count) {
            let left = index < lhsParts.count ? lhsParts[index] : 0
            let right = index < rhsParts.count ? rhsParts[index] : 0
            if left != right {
                return left < right
            }
        }

        return lhs.version < rhs.version
    }
}
