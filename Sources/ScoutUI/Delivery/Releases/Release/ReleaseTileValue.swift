//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseTileValue {
    enum Kind: CaseIterable {
        case crashFree
        case adoption
        case crashes
        case hangs
        case resources
        case exits
        case launchTime
        case peakMemory

        var title: String {
            switch self {
            case .crashFree: "Crash-free sessions"
            case .adoption: "Adoption"
            case .crashes: "Crashes"
            case .hangs: "Hangs"
            case .resources: "Resources"
            case .exits: "Abnormal exits"
            case .launchTime: "Launch time"
            case .peakMemory: "Peak memory"
            }
        }
    }

    let kind: Kind
    let value: String
    let color: Color
    let chart: ReleaseChart
    let footer: String?
}

enum ReleaseChart {
    case zones(Double)
    case progress(Double)
    case bars([Int], Color?)
    case segments([Double])
}

struct ReleaseHangRate {
    let value: String
    let change: String?
    let color: Color
}
