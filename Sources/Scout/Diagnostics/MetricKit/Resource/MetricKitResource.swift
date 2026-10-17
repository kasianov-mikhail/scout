//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package enum ResourceKind: String, Sendable {
    case cpu
    case diskWrite = "disk_write"
}

struct MetricKitResource: MetricKitIncident, Sendable {
    let kind: ResourceKind
    let amount: Double
    let sampledSeconds: Double?
    let appVersion: String?
    let processID: Int32?
    let window: DateInterval
    let frames: [MetricKitStackTree.Frame]
}

extension MetricKitResource {
    var name: String {
        switch kind {
        case .cpu: "CPU Exception"
        case .diskWrite: "Disk Write Exception"
        }
    }

    var reason: String? {
        switch kind {
        case .cpu:
            if let sampledSeconds {
                String(format: "%.0f s of CPU time in %.0f s", amount, sampledSeconds)
            } else {
                String(format: "%.0f s of CPU time", amount)
            }
        case .diskWrite:
            String(format: "%.0f MB written to disk", amount / 1_048_576)
        }
    }

    var id: UUID {
        UUID(
            digesting: [
                kind.rawValue,
                String(amount),
                appVersion ?? "",
                processID.map(String.init) ?? "",
                String(window.start.timeIntervalSince1970),
                String(window.end.timeIntervalSince1970),
            ] + stackTrace
        )
    }
}
