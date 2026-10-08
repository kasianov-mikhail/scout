//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@available(iOS 18, macOS 15, *)
extension CachedDatabase: AudienceReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        try await base.activity(in: range)
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        try await base.retention(in: range)
    }
}
