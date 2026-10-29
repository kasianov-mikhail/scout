//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

enum HapticFeedback {
    case selection
    case success
}

extension View {
    @ViewBuilder
    func hapticFeedback<T: Equatable>(_ feedback: HapticFeedback, trigger: T) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            sensoryFeedback(feedback.resolved, trigger: trigger)
        } else {
            self
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension HapticFeedback {
    fileprivate var resolved: SensoryFeedback {
        switch self {
        case .selection: .selection
        case .success: .success
        }
    }
}
