//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package enum RetentionMilestone: Hashable, Sendable {
    case install
    case day(Int)
    case crash
    case hang
}

extension RetentionMilestone {
    package var name: String {
        switch self {
        case .install: "install"
        case .day(let offset): "day\(offset)"
        case .crash: "crash"
        case .hang: "hang"
        }
    }

    package init?(name: String) {
        switch name {
        case "install":
            self = .install
        case "crash":
            self = .crash
        case "hang":
            self = .hang
        default:
            guard name.hasPrefix("day"), let offset = Int(name.dropFirst(3)) else {
                return nil
            }
            self = .day(offset)
        }
    }
}
