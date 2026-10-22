//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension NativeDatabase: IncidentReader {
    func incidentTallies(recordType: String, in range: Range<Date>) async throws -> [IncidentTally] {
        let points = try await resolve().query(recordType).series(metric: .sum, group: "fingerprint", in: range)

        return Dictionary(grouping: points.filter { !$0.group.isEmpty }, by: \.group).compactMap { fingerprint, points in
            guard let first = points.map(\.date).min() else {
                return nil
            }
            return IncidentTally(
                fingerprint: fingerprint,
                count: Int(points.reduce(0) { $0 + $1.value }),
                firstHour: first
            )
        }
    }
}
