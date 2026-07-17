//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A weekly retention cohort.
///
/// The install week, its size, and the retained fraction at each ``dayOffsets``
/// milestone (`nil` where the milestone has not elapsed). It is what a
/// ``Database`` returns from its retention query.
///
public struct RetentionCohort: Identifiable, Hashable, Sendable {
    public static let dayOffsets = [0, 1, 3, 7, 14, 30]
    public static let summaryOffsets = [1, 7, 30]

    public let id: Date
    public let size: Int
    public let retention: [Double?]

    public init(id: Date, size: Int, retention: [Double?]) {
        self.id = id
        self.size = size
        self.retention = retention
    }
}

extension RetentionCohort {
    /// Maps a wire cohort — a week start in epoch milliseconds, an install
    /// count, and a retained count per ``dayOffsets`` milestone (`nil` where the
    /// milestone has not elapsed) — into display rates.
    ///
    public init(date: Int64, size: Int, retained: [Int?]) {
        self.init(
            id: Date(millisecondsSince1970: date),
            size: size,
            retention: retained.map { count in
                guard let count, size > 0 else { return nil }
                return Double(count) / Double(size)
            }
        )
    }
}
