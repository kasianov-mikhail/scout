//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A protocol that defines the requirements for a type to be used in a period picker.
protocol PickerCompatible: Hashable {

    /// The title of the period. Should be short and suitable for display in a picker.
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
