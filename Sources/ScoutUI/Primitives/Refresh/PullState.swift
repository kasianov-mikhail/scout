//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct PullState: Equatable {
    enum Phase {
        case idle
        case refreshing
        case retracting
    }

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
