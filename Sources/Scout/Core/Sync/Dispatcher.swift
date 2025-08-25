//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

actor Dispatcher {
    private var isRunning = false

    func execute(_ block: @escaping () async throws -> Void) async rethrows {
        guard !isRunning else {
            return
        }

        isRunning = true

        defer {
            isRunning = false
        }

        try await block()
    }
}
