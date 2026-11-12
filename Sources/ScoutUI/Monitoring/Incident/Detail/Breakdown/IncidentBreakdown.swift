//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct IncidentBreakdown: Equatable {
    let devices: [Segment]
    let osVersions: [Segment]
    let appVersions: [Segment]
    let modelsByDevice: [UUID: String]
    let appVersionsBySession: [UUID: String]

    init(devices: [Segment], osVersions: [Segment], appVersions: [Segment], modelsByDevice: [UUID: String] = [:], appVersionsBySession: [UUID: String] = [:]) {
        self.devices = devices
        self.osVersions = osVersions
        self.appVersions = appVersions
        self.modelsByDevice = modelsByDevice
        self.appVersionsBySession = appVersionsBySession
    }
}

extension IncidentBreakdown {
    var affected: [IncidentAffected] {
        [
            IncidentAffected(title: IncidentAffected.titles[0], segments: devices, usesDeviceNames: true),
            IncidentAffected(title: IncidentAffected.titles[1], segments: osVersions),
            IncidentAffected(title: IncidentAffected.titles[2], segments: appVersions),
        ]
        .filter { !$0.segments.isEmpty }
    }

    func occurrenceLabel<Element: Incident>(record: Element) -> String? {
        var parts: [String] = []
        if let detail = record.summaryDetail {
            parts.append(detail)
        }
        if let deviceID = record.deviceID, let model = modelsByDevice[deviceID] {
            parts.append(DeviceModel(identifier: model).name)
        }
        if Element.kind != .resource, let sessionID = record.sessionID, let version = appVersionsBySession[sessionID] {
            parts.append(version)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

extension IncidentBreakdown {
    static func segments(from labels: [String], top: Int = 4) -> [Segment] {
        let counts = Dictionary(labels.map { ($0, 1) }, uniquingKeysWith: +)
        let ranked = counts.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }

        var segments = zip(ranked.prefix(top), colors).map { pair, color in
            Segment(label: pair.key, count: pair.value, color: color)
        }

        let other = ranked.count > top ? ranked[top...].reduce(0) { $0 + $1.value } : 0
        if other > 0 {
            segments.append(Segment(count: other, color: .gray, kind: .other))
        }

        return segments
    }

    private static let colors: [Color] = [.blue, .indigo, .purple, .teal]
}

extension IncidentBreakdown {
    static var sample: IncidentBreakdown {
        IncidentBreakdown(
            devices: segments(
                from: Array(repeating: "iPhone15,3", count: 5) + Array(repeating: "iPhone14,2", count: 3)
                    + Array(repeating: "iPhone13,2", count: 2) + [
                        "iPad13,1"
                    ]),
            osVersions: segments(
                from: Array(repeating: "iOS 17.4", count: 6) + Array(repeating: "iOS 17.3", count: 3)
                    + Array(repeating: "iOS 16.7", count: 2)),
            appVersions: segments(
                from: Array(repeating: "3.2.0", count: 10) + Array(repeating: "3.1.4", count: 2))
        )
    }
}
