//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct RetentionCohort: Identifiable, Hashable, Sendable {
    package static let dayOffsets = [0, 1, 3, 7, 14, 30]

    package let id: Date
    package let size: Int
    package let retention: [Double?]
    package let segments: [RetentionSegment]

    package init(id: Date, size: Int, retention: [Double?], segments: [RetentionSegment]) {
        self.id = id
        self.size = size
        self.retention = retention
        self.segments = segments
    }
}

extension RetentionCohort: Comparable {
    package static func < (lhs: RetentionCohort, rhs: RetentionCohort) -> Bool {
        lhs.id < rhs.id
    }
}

extension RetentionCohort {
    package static func rate(_ retention: [Double?], onDay day: Int) -> Double? {
        guard let index = dayOffsets.firstIndex(of: day), retention.indices.contains(index) else {
            return nil
        }
        return retention[index]
    }
}
