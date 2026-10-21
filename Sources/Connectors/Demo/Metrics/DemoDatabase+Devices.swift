//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout

extension DemoDatabase: DeviceReader {
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        [DeviceActivity](
            devices: records(of: DeviceEntry.recordType),
            sessions: records(of: SessionEntry.recordType).filter { range.contains(date: $0["start_date"]) },
            crashes: records(of: CrashEntry.recordType).filter { range.contains(date: $0["date"]) }
        )
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        records(of: SessionEntry.recordType).deviceCounts(in: ranges)
    }

    private func records(of type: String) -> [Record] {
        records.filter { $0.recordType == type }
    }
}

extension Range<Date> {
    fileprivate func contains(date: Date?) -> Bool {
        date.map(contains) ?? false
    }
}
