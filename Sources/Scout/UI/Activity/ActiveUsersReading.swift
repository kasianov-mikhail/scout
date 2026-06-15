//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A backend that answers DAU/WAU/MAU natively.
///
/// CloudKit cannot aggregate, so the client reconstructs active users from the
/// hand-maintained `ActiveUser` `PeriodMatrix`. A Scout server aggregates over
/// raw `Session` records and serves the finished series, sparing the client
/// that bookkeeping.
///
protocol ActiveUsersReading {
    func activeUsers(in range: Range<Date>) async throws -> [ActiveUserPoint]
}

/// One day of the series: distinct active installs as of `date`, counted over
/// the trailing day (`dau`), 7 days (`wau`), and calendar month (`mau`).
///
/// `date` is milliseconds since the Unix epoch at UTC midnight, matching the
/// rest of the wire format.
///
struct ActiveUserPoint: Decodable, Equatable {
    let date: Int64
    let dau: Int
    let wau: Int
    let mau: Int
}
