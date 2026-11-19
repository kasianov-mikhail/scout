//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DeviceDetail {
    init(summary: DeviceSummary, range: IncidentRange, sessions: [Session], crashes: [Crash], hangs: [Hang], resources: [ResourceException], installs: [Install], versions: [Version], now: Date) {
        let crashSessions = Set(crashes.compactMap(\.sessionID))
        let recent =
            sessions
            .sorted { ($0.startDate ?? .distantPast) > ($1.startDate ?? .distantPast) }
            .prefix(5)
            .compactMap { session -> DeviceSession? in
                guard let startDate = session.startDate else {
                    return nil
                }
                return DeviceSession(
                    id: session.id,
                    sessionID: session.sessionID,
                    startDate: startDate,
                    endDate: session.endDate,
                    appVersion: session.appVersion,
                    crashed: session.sessionID.map(crashSessions.contains) ?? false
                )
            }

        self.init(
            summary: summary,
            crashes: crashes.count,
            hangs: hangs.count,
            resources: resources.count,
            recentSessions: Array(recent),
            history: [DeviceHistoryEvent](installs: installs, versions: versions, sessions: sessions),
            activity: DeviceActivityPoint.points(sessions: sessions, range: range, now: now),
            usage: DeviceUsage(sessions: sessions),
            range: range,
            medianDuration: sessions.compactMap(\.duration).median
        )
    }
}

extension Session {
    var duration: TimeInterval? {
        guard let startDate, let endDate, endDate >= startDate else {
            return nil
        }
        return endDate.timeIntervalSince(startDate)
    }
}
