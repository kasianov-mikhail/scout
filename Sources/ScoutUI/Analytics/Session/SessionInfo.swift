//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct SessionInfo: Equatable {
    var model: String? = nil
    var osVersion: String? = nil
    var locale: String? = nil
    var channel: String? = nil
    var appVersion: String? = nil
    var buildNumber: String? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil

    var version: String? {
        guard let appVersion else { return nil }
        return buildNumber.map { "v\(appVersion) (\($0))" } ?? "v\(appVersion)"
    }

    var duration: String? {
        guard let startDate, let endDate, endDate >= startDate else { return nil }

        let seconds = Int(endDate.timeIntervalSince(startDate))
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder > 0 ? "\(hours)h \(remainder)m" : "\(hours)h"
    }

    var channelColor: Color {
        switch channel {
        case "App Store": .green
        case "TestFlight": .orange
        default: .gray
        }
    }

    var channelIcon: String {
        switch channel {
        case "App Store": "app.badge"
        case "TestFlight": "airplane"
        default: "hammer"
        }
    }
}

extension SessionInfo {
    static var sample: SessionInfo {
        SessionInfo(
            model: "iPhone16,1",
            osVersion: "iOS 17.4",
            locale: "en-US",
            channel: "TestFlight",
            appVersion: "2.3.1",
            buildNumber: "412",
            startDate: Date(timeIntervalSinceNow: -720),
            endDate: Date()
        )
    }
}
