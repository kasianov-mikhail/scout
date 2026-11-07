//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct SessionInfo: Equatable {
    var model: String? = nil
    var osVersion: String? = nil
    var locale: String? = nil
    var channel: String? = nil
    var appVersion: String? = nil
    var buildNumber: String? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    var launchDate: Date? = nil
    var launchOpen: Bool = false

    var isLive: Bool {
        endDate == nil && launchOpen
    }

    var version: String? {
        guard let appVersion else { return nil }
        return buildNumber.map { "\(appVersion) (\($0))" } ?? appVersion
    }

    var duration: String? {
        guard let startDate, let endDate, endDate >= startDate else {
            return nil
        }
        return endDate.timeIntervalSince(startDate).sessionDuration
    }

    var detail: String? {
        guard let startDate else { return nil }
        let day = sessionDayFormatter.string(from: startDate)
        let start = sessionTimeFormatter.string(from: startDate)
        let range: String
        if let endDate, endDate >= startDate {
            range = "\(start) – \(sessionTimeFormatter.string(from: endDate))"
        } else if isLive {
            range = "\(start) – now"
        } else {
            range = start
        }
        return "\(day) · \(range)"
    }

    var summary: String? {
        let value = [duration, detail].compactMap { $0 }.joined(separator: " · ")
        return value.isEmpty ? nil : value
    }
}

extension SessionInfo {
    static var sample: SessionInfo {
        let startDate = Date(timeIntervalSince1970: 1_761_403_200)
        return SessionInfo(
            model: "iPhone16,1",
            osVersion: "iOS 17.4",
            locale: "en-US",
            channel: "TestFlight",
            appVersion: "2.3.1",
            buildNumber: "412",
            startDate: startDate,
            endDate: startDate.addingTimeInterval(732),
            launchDate: startDate.addingTimeInterval(-4)
        )
    }
}

extension TimeInterval {
    var sessionDuration: String {
        let total = Int(max(self, 0).rounded())
        let hours = total / 3_600
        let minutes = total % 3_600 / 60
        let seconds = total % 60

        if hours > 0 {
            if minutes == 0 {
                return "\(hours) h"
            }
            return seconds == 0 ? "\(hours) h \(minutes) min" : "\(hours) h \(minutes) min \(seconds) s"
        }
        if minutes > 0 {
            return seconds == 0 ? "\(minutes) min" : "\(minutes) min \(seconds) s"
        }
        return "\(seconds) s"
    }

    var sessionOffset: String {
        let total = Int(max(self, 0).rounded())
        return String(format: "+%d:%02d", total / 60, total % 60)
    }
}

private let sessionDayFormatter = DateFormatter(format: "EEE, MMM d")
private let sessionTimeFormatter = DateFormatter(format: "HH:mm")
