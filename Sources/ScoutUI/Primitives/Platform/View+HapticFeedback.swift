//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

enum HapticFeedback {
    case selection
    case success
    case impact
}

extension View {
    /// Plays haptic feedback when `trigger` changes, degrading to no feedback
    /// on the iOS 16 / macOS 13 floor where `sensoryFeedback` is unavailable.
    ///
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
        case .impact: .impact
        }
    }
}
