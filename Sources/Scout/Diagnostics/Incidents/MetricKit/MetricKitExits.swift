//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricKitExits: Sendable {
    let counts: [ExitReason: Int]
    let appVersion: String?
    let window: DateInterval
}

extension MetricKitExits {
    init(foreground: [ExitReason: Int], background: [ExitReason: Int], appVersion: String?, window: DateInterval) {
        let counts = foreground.merging(background, uniquingKeysWith: +).filter { $0.value > 0 }
        self.init(counts: counts, appVersion: appVersion, window: window)
    }

    func id(of reason: ExitReason, installID: UUID) -> UUID {
        UUID(digesting: [
            installID.uuidString,
            reason.rawValue,
            appVersion ?? "",
            String(window.start.timeIntervalSince1970),
            String(window.end.timeIntervalSince1970),
        ])
    }
}
