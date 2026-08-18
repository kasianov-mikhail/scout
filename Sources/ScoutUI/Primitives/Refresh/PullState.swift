//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct PullState: Equatable {
    enum Phase {
        case idle
        case refreshing
        case retracting
    }

    // Content insets can settle a fraction of a point off their rest offset,
    // which must not read as a lingering pull.
    static let slack: CGFloat = 1

    let threshold: CGFloat

    private(set) var pull: CGFloat = 0
    private(set) var phase: Phase = .idle
    private(set) var isArmed = true

    init(threshold: CGFloat = 58) {
        self.threshold = threshold
    }

    var isRefreshing: Bool {
        phase == .refreshing
    }

    var isVisible: Bool {
        phase != .idle || (isArmed && pull > 0)
    }

    var inset: CGFloat {
        isRefreshing ? threshold : 0
    }

    var progress: Double? {
        phase == .idle ? min(pull / threshold, 1) : nil
    }

    // While retracting the ring follows the animated inset rather than the
    // measured pull, which UIKit clamps to zero the moment the inset shrinks.
    func ringOffset(size: CGFloat) -> CGFloat {
        (phase == .retracting ? inset : pull) - (threshold + size) / 2
    }

    var ringScale: CGFloat {
        phase == .retracting ? 0 : 1
    }

    mutating func update(pull: CGFloat, dragging: Bool = true) -> Bool {
        self.pull = pull < Self.slack ? 0 : pull

        if self.pull == 0 {
            isArmed = true
        }

        guard dragging, self.pull >= threshold else {
            return false
        }

        return trigger()
    }

    mutating func trigger() -> Bool {
        guard phase == .idle, isArmed else {
            return false
        }

        phase = .refreshing
        isArmed = false
        return true
    }

    mutating func finish() {
        guard isRefreshing else { return }
        phase = .retracting
    }

    mutating func settle() {
        guard phase == .retracting else {
            return
        }

        phase = .idle
    }
}
