//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol PickerCompatible: Hashable {
    var shortTitle: String { get }
}

extension ActivityPeriod: PickerCompatible {
    var shortTitle: String {
        rawValue.uppercased()
    }
}

extension Period: PickerCompatible {
    var shortTitle: String {
        switch self {
        case .today:
            "T"
        case .yesterday:
            "Y"
        case .week:
            "7"
        case .month:
            "30"
        case .year:
            "365"
        }
    }
}
