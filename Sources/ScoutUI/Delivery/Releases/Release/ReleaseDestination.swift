//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

enum ReleaseDestination: Hashable {
    case crashes
    case hangs
    case resources
}

extension ReleaseTileValue.Kind {
    var destination: ReleaseDestination? {
        switch self {
        case .crashes: .crashes
        case .hangs: .hangs
        case .resources: .resources
        case .crashFree, .adoption, .exits, .launchTime, .peakMemory: nil
        }
    }
}
