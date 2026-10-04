//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct RetentionSegment: Identifiable, Hashable, Sendable {
    package let name: String
    package let size: Int
    package let retention: [Double?]
    package let crashes: Int
    package let hangs: Int

    package var id: String { name }

    package init(name: String, size: Int, retention: [Double?], crashes: Int, hangs: Int) {
        self.name = name
        self.size = size
        self.retention = retention
        self.crashes = crashes
        self.hangs = hangs
    }
}

extension RetentionSegment: Comparable {
    package static func < (lhs: RetentionSegment, rhs: RetentionSegment) -> Bool {
        if lhs.size != rhs.size {
            return lhs.size > rhs.size
        }
        if lhs.major != rhs.major {
            return lhs.major > rhs.major
        }
        return lhs.name < rhs.name
    }

    private var major: Int {
        Int(name.split(separator: " ").last ?? "") ?? 0
    }
}
