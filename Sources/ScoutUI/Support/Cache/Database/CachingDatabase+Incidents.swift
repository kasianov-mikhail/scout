//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension CachingDatabase: IncidentReader {
    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        try await base.incidentIndex(recordType: recordType, in: range)
    }
}
