//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DemoDatabase: AudienceReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        activityPoints.filter { range.contains(Date(millisecondsSince1970: $0.date)) }
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        retentionCohorts.filter { range.contains($0.id) }
    }
}
