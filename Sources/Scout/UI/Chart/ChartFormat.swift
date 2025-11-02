//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar.Component {
    var chartFormat: Date.FormatStyle {
        var style = Date.FormatStyle()
        style.timeZone = TimeZone(secondsFromGMT: 0)!

        return switch self {
        case .hour:
            style.hour(.twoDigits(amPM: .omitted))
        case .day:
            style.day(.defaultDigits).month(.abbreviated)
        case .month:
            style.month(.abbreviated).year(.twoDigits)
        default:
            style
        }
    }
}
