//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ScoutCore
import SwiftUI

struct IncidentBreakdown: Equatable {
    let devices: [Segment]
    let osVersions: [Segment]
    let modelsByDevice: [UUID: String]
    let versionsBySession: [UUID: String]

    init(
        devices: [Segment], osVersions: [Segment], modelsByDevice: [UUID: String] = [:],
        versionsBySession: [UUID: String] = [:]
    ) {
        self.devices = devices
        self.osVersions = osVersions
        self.modelsByDevice = modelsByDevice
        self.versionsBySession = versionsBySession
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
            segments.append(Segment(label: "Other", count: other, color: .gray))
        }

        return segments
    }

    private static let colors: [Color] = [.blue, .indigo, .purple, .teal]
}

extension IncidentBreakdown {
    enum Dimension {
        case devices
        case osVersions
    }

    func records<Element: SessionContext>(from records: [Element], in dimension: Dimension, matching segment: Segment)
        -> [Element]
    {
        guard segment.label == "Other" else {
            return records.filter { label(of: $0, in: dimension) == segment.label }
        }

        let named = Set(segments(in: dimension).map(\.label))
        return records.filter { record in
            guard let label = label(of: record, in: dimension) else { return false }
            return !named.contains(label)
        }
    }

    private func segments(in dimension: Dimension) -> [Segment] {
        switch dimension {
        case .devices:
            devices
        case .osVersions:
            osVersions
        }
    }

    private func label<Element: SessionContext>(of record: Element, in dimension: Dimension) -> String? {
        switch dimension {
        case .devices:
            record.deviceID.flatMap { modelsByDevice[$0] }
        case .osVersions:
            record.sessionID.flatMap { versionsBySession[$0] }
        }
    }
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
                    + Array(repeating: "iOS 16.7", count: 2))
        )
    }
}
