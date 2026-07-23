//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

typealias RefreshAction = @MainActor () async -> Bool

private let seeds = (3, 5)
private let maxSeconds = 89

final class RefreshSchedule {
    private let refreshers: [RefreshAction]
    private var current = seeds.0
    private var next = seeds.1

    init(_ refreshers: [RefreshAction]) {
        self.refreshers = refreshers
    }

    init(_ refresher: @escaping RefreshAction) {
        self.refreshers = [refresher]
    }

    func rotate() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(current))
            } catch {
                break
            }

            var isSuccess = true

            for refresh in refreshers {
                if Task.isCancelled {
                    return
                } else if await refresh() == false {
                    isSuccess = false
                }
            }

            if isSuccess {
                (current, next) = seeds
            } else {
                (current, next) = (next, min(current + next, maxSeconds))
            }
        }
    }
}
