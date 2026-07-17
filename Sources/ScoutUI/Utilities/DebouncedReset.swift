//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

// Schedules a delayed action, cancelling any previously scheduled one so that
// only the most recent call takes effect once the delay elapses.
struct DebouncedReset {
    private var task: Task<Void, Never>?

    mutating func schedule(after delay: Duration, _ action: @MainActor @escaping () -> Void) {
        task?.cancel()
        task = Task { @MainActor in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            action()
        }
    }

    mutating func cancel() {
        task?.cancel()
        task = nil
    }
}
