//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum GlobalSearchHit: Identifiable {
    case event(name: String)
    case metric(name: String, telemetry: Telemetry.Export)
    case endpoint(name: String)
    case device(DeviceSummary)
    case release(ReleaseHealth)
    case crash(IncidentGroup<Crash>)
    case hang(IncidentGroup<Hang>)

    var category: GlobalSearchCategory {
        switch self {
        case .event:
            .events
        case .metric:
            .metrics
        case .endpoint:
            .network
        case .device:
            .devices
        case .release:
            .releases
        case .crash:
            .crashes
        case .hang:
            .hangs
        }
    }

    var title: String {
        switch self {
        case .event(let name), .metric(let name, _), .endpoint(let name):
            name
        case .device(let device):
            device.modelName
        case .release(let release):
            release.id
        case .crash(let group):
            group.name
        case .hang(let group):
            group.name
        }
    }

    var id: String {
        switch self {
        case .device(let device):
            "\(category.rawValue):\(device.id)"
        case .crash(let group):
            "\(category.rawValue):\(group.id)"
        case .hang(let group):
            "\(category.rawValue):\(group.id)"
        default:
            "\(category.rawValue):\(title)"
        }
    }
}
