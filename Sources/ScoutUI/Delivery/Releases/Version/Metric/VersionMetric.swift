//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

enum VersionMetric: CaseIterable {
    case stability
    case adoption
    case crashes
    case hangs
    case resources
    case exits
    case launch
    case memory

    var title: String {
        switch self {
        case .stability: "Crash-free sessions"
        case .adoption: "Adoption"
        case .crashes: "Crashes"
        case .hangs: "Hangs"
        case .resources: "Resources"
        case .exits: "Abnormal exits"
        case .launch: "Launch time"
        case .memory: "Peak memory"
        }
    }
}
