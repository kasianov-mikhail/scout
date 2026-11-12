//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension Color {
    static let crashText = textDanger
    static let hangText = textWarning
    static let resourceText = textResource
}

extension IncidentKind {
    var detailColor: Color {
        switch self {
        case .crash:
            .crashText
        case .hang:
            .hangText
        case .resource:
            .resourceText
        }
    }

    var detailBackground: Color {
        switch self {
        case .crash:
            .tintDanger
        case .hang:
            .tintWarning
        case .resource:
            .tintResource
        }
    }
}
