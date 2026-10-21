//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension CachingDatabase: DeviceReader {
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        try await base.devices(in: range)
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        try await base.deviceCounts(in: ranges)
    }
}
