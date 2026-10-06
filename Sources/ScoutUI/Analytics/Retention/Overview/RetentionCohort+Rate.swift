//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RetentionCohort {
    static func rate(_ retention: [Double?], onDay day: Int) -> Double? {
        guard let index = dayOffsets.firstIndex(of: day), retention.indices.contains(index) else {
            return nil
        }
        return retention[index]
    }
}
